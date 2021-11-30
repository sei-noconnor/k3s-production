#!/bin/sh -xe
# 
# Copyright 2021 Carnegie Mellon University.
# Released under a BSD (SEI)-style license, please see LICENSE.md in the
# project root or contact permission@sei.cmu.edu for full terms.

#############################
#   Identity Seed Script    #
#############################

# WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING #
#                                                                                         #
# If you are dependant on the id or globalId of an item use the Identity seed file        #
# In many cases this script will delete and re-create items due to limitation of the      #
# Identity API                                                                            #
#                                                                                         #
# WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING #    

app_name=${1}
# If json files are not in the same directory as the script 
# Specify the directory as the second argument.
directory=${2-$(dirname "$BASH_SOURCE[0]")}
cd $directory

# http or https
proto="https"
domain="${domain:-$DOMAIN}"

# get access token
req=$(curl --silent --insecure --request POST \
  --url "$proto://$domain/identity/connect/token" \
  --data grant_type=password \
  --data scope="identity-api identity-api-privileged" \
  --data client_id=bootstrap-client \
  --data client_secret=foundry \
  --data username=administrator@$domain \
  --data password=$ADMIN_PASS)
  
  access_token=$(echo $req | jq -r '.access_token')
  if [[ -z $access_token ]]; then 
    echo "$req | jq -r '.message"
    exit 1;
  fi



# Function exists() 
# Returns id if the item exists
# returns empty string if it doesn't. 
function exists() {
  type=$1
  name=$2

  url="$proto://$domain/identity/api/${type}s?term=$name"
  exists=$(curl --silent --insecure --request GET \
    --url "$url" \
    -H "Authorization: Bearer $access_token" \
    -H "Content-type: application/json")
  # RETURN
   echo $(printf '%s' "$exists" | jq '.[0].id // empty')
}

function update() {
  # type can also be used like a path "resource/enlist" without the quotes
  type=$1
  name=$2
  id=$3
  data=$4
  
  url="$proto://$domain/identity/api/${type}"
  

  api_json=$(curl --silent --insecure --request GET \
    --url "$url/$id" \
    -H "Authorization: Bearer $access_token" \
    -H "Content-type: application/json" | jq '.')
  
  #Combine file and API json
  json=$(printf '%s' "$api_json $data" | jq -sr add)
  updated=$(curl --silent --insecure --request PUT \
  --url "$url" \
  -H "Authorization: Bearer $access_token" \
  -H "Content-type: application/json" \
  -d "$json")
  if [[ -n "$updated" ]]; then 
    echo "$name Updated" 
  fi
}

function add() {
  type=$1
  name=$2
  data=$3
  # props is a jq filter string
  # In some cases when creating we need a subset of the json data
  # e.g. '. | {usernames: .usernames, password: .password}'
  props=${4-'.'}
  url="$proto://$domain/identity/api/${type}"
  
  # Parse json for initial POST
    init_json=$(printf '%s' "$data" | jq "$props")
    echo "CREATING NEW $type"
    #Create the resource, get the resource id and full resource.
    init_api=$(curl --silent --insecure --request POST \
    --url "$url" \
    -H "Authorization: Bearer $access_token" \
    -H "Content-type: application/json" \
    -d "$init_json")
    
    id=$(printf '%s' "$init_api" |jq -r '. | if type=="array" then .[0].id else .id end // empty')
    
    if [[ -n "$id" ]]; then
      api_json=$(curl --silent --insecure --request GET \
      --url "$url/$id" \
      -H "Authorization: Bearer $access_token" \
      -H "Content-type: application/json")

      # Merge json
      json=$(printf '%s\n%s\n' "$api_json" "$data" | jq -n '[inputs] | add')
      
      # PUT Update
      added=$(curl --silent --insecure --request PUT \
      --url "$proto://$domain/identity/api/$type" \
      -H "Authorization: Bearer $access_token" \
      -H "Content-type: application/json" \
      -d "$json" | jq -r '.')
      if [[ -n "$added" ]]; then 
        echo $added
        # Check client scope
        # In some cases the Identity API will create a client successfully but omit scope resources
        # if they don't exists. This can cause authorization to fail, due to invalid scopes. In this 
        # case we assume that if a scope is specified it is required. We fail the script if data 
        # scope and added scope do not match so that the init container will restart and try again.
        if [[ "$type" == "client" ]]; then
          data_scopes=$(printf '%s' "$data" | jq -r '.scopes')
          add_scopes=$(printf '%s' "$added" | jq -r '.scopes')
          if [[ "$data_scopes" != "$add_scopes" ]]; then 
            echo "Intended Scopes: $data_scopes"
            echo "Created Scopes: $add_scopes\n\n"
            echo "Compare the scopes and make sure the missing scopes application initialized correctly."
            echo "In most cases this is a race condition and a retry is all that is needed.\n"
            echo "Sleeping for 10 seconds before exiting..."
            sleep 10
            exit 1
          fi
        fi
      fi
    fi
}

function delete() {
  type=$1
  name=$2
  id=$3
  url="$proto://$domain/identity/api/${type}"
  exists=$(curl --silent --insecure --request DELETE \
    --url "$url/$id" \
    -H "Authorization: Bearer $access_token" \
    -H "Content-type: application/json")
  # RETURN
   echo $(printf '%s' "$exists" | jq '.[0].id // empty')
}

# Checks if the file is an array or object 
# Objects will be returned as an array
function isArray() {
  file=$1
  ret=$(jq -rc '. | if type!="array" then [.] else . end' "$file")
  echo $ret
}

#If Resource json exists. Configure Resource
if [[ -e "${directory}/$app_name-resource.json" ]]; then
  file="${directory}/$app_name-resource.json"
  isArray $file | jq -c '.[]' | while read object; do
    name=$(printf '%s' "$object" | jq -r '.name')
    resource_id=$(exists resource $name)
    
    if [[ -n "$resource_id" ]]; then  
      # Because of some API limitations, delete the resource and add it again
      delete resource $name $resource_id
      add resource $name "$object"
    else
      add resource $name "$object"
    fi
  done
fi


#If a client json file exists. Configure Client. 
if [[ -e "${directory}/$app_name-client.json" ]]; then
  file="${directory}/$app_name-client.json"
  isArray $file | jq -c '.[]' | while read object; do
    name=$(printf '%s' "$object" | jq -r '.name')
    client_id=$(exists client $name)
    
    if [[ -n "$client_id" ]]; then  
      # Because of some API limitations, delete the client and add it again
      delete client $name $client_id
      add client $name "$object" '. | {name: .name, displayName: .displayName, description: .description}'
    else
      add client $name "$object" '. | {name: .name, displayName: .displayName, description: .description}'
    fi
  done
fi

#If a account json file exists. Create Account as long as it doesn't exist. 
if [[ -e "${directory}/$app_name-account.json" ]]; then
  file="${directory}/$app_name-account.json"
  isArray $file | jq -c '.[]' | while read object; do
    username=$(printf '%s' "$object" | jq -r '.usernames[0]')
    account_id=$(exists account $username)
    
    if [[ -n "$account_id" ]]; then  
      # Because of some API limitations, delete the resource and add it again
      echo "Account Exists. Accounts cannot be updated with this script."
    else
      add account $username "$object" '. | {usernames: .usernames, password: .password}'
    fi
  done
fi
