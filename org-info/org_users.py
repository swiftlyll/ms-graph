#!/usr/bin/python

'''
Author: Kennet
Date: 2025-01-20
GitHub: https://github.com/swiftlyll
Description: Retrives users based on requested attributes.
'''

import os
import asyncio
from azure.identity.aio import ClientSecretCredential
from msgraph.generated.users.users_request_builder import UsersRequestBuilder # parameters
from kiota_abstractions.base_request_configuration import RequestConfiguration # create request
from msgraph import GraphServiceClient

import json
from kiota_serialization_json.json_serialization_writer_factory import JsonSerializationWriterFactory # for json serialization bytes->str->dic

# client
credentials = ClientSecretCredential(
    tenant_id = os.environ["TENANT_ID"],
    client_id = os.environ["CLIENT_ID"],
    client_secret = os.environ["GRAPH_API_KEY"]
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

# functions
def convert_dic(graph_output):
    writer = JsonSerializationWriterFactory().get_serialization_writer("application/json")
    graph_output.serialize(writer=writer) # coverts "graph_output" to bytes
    graph_output_bytes = writer.get_serialized_content() # get serialized content and store in variable
    graph_output_string = graph_output_bytes.decode("utf-8") # convert bytes to string
    graph_output_dic = json.loads(graph_output_string) # convert string to dic
    # graph_output_json = json.dumps(graph_output_dic,indent=4) # pretty JSON output for visualization
    
    return graph_output_dic
    # return graph_output_json

# script
async def get_users():
    users = await client.users.get(request_configuration=request_config)
    users = convert_dic(graph_output=users)

    for user in users.get("value",'"Value" dictonary does not exist'): # enters nested dic "value" containing user list
        print(user.get("id","Not Available!"))
        print(user.get("displayName","Not Available!"))
        print(user.get("userPrincipalName","Not Available!"))
        ""

asyncio.run(get_users())
input("Press ENTER to exit")