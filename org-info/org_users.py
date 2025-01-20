# Date: 2025-01-20

import os
import asyncio
from azure.identity.aio import ClientSecretCredential
from msgraph.generated.users.users_request_builder import UsersRequestBuilder # parameters
from kiota_abstractions.base_request_configuration import RequestConfiguration # create request
from msgraph import GraphServiceClient

import json
from kiota_serialization_json.json_serialization_writer_factory import JsonSerializationWriterFactory # for json serialization bytes->str->dic

credentials = ClientSecretCredential(
    tenant_id = os.environ['TENANT_ID'],
    client_id = os.environ['CLIENT_ID'],
    client_secret = os.environ['GRAPH_API_KEY']
)
scopes = ["https://graph.microsoft.com/.default"] # uses scopes assigned to app in entra
client = GraphServiceClient(credentials=credentials,scopes=scopes)
query_params = UsersRequestBuilder.UsersRequestBuilderGetQueryParameters(
    # filter = f"displayName eq '{user_input}'",
    top = 10 # range = 1-999, if not enough use "@odata.nextLink" returned in header
    # $top default to 100 entries due to paging limit
    # paging limit limits the amount of results returned at once
    # see here: https://learn.microsoft.com/en-us/graph/paging
)
request_config = RequestConfiguration(
    query_parameters = query_params
) 

async def get_users():
    users = await client.users.get(request_configuration=request_config)
    
    writer = JsonSerializationWriterFactory().get_serialization_writer('application/json')
    users.serialize(writer=writer) # coverts "users" to bytes
    users_bytes = writer.get_serialized_content() # get serialized content and store in variable
    users_string = users_bytes.decode("utf-8") # convert bytes to string
    users_dic = json.loads(users_string) # convert string to dic
    # users_json = json.dumps(users_dic,indent=4) # pretty JSON output for visualization
    
    for user in users.value: # for user inside the value dictionary
        print(user.id)
        
        # both methods return the same
        print(user.display_name)
        print(users_dic['value'][0].get('displayName','Not Available!'))

asyncio.run(get_users())
input('Press ENTER to exit')