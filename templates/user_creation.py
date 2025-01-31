#!/usr/bin/python

'''
Author: Kennet
Date: 2025-01-31
GitHub: https://github.com/swiftlyll
Description: Template for creating user accounts.
'''

import os
import asyncio
from msgraph import GraphServiceClient
from msgraph.generated.models.user import User
from msgraph.generated.models.password_profile import PasswordProfile
from azure.identity.aio import ClientSecretCredential

# client
credentials = ClientSecretCredential(
    tenant_id = os.environ["TENANT_ID"],
    client_id = os.environ["CLIENT_ID"],
    client_secret = os.environ["GRAPH_API_KEY"]
)
scopes = ["https://graph.microsoft.com/.default"] # uses scopes assigned to app in entra
client = GraphServiceClient(credentials=credentials,scopes=scopes)

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
request_body = User(
    account_enabled = True,
    display_name = "API Test",
    given_name = "API",
    surname = "Test",
    mail_nickname = "api_test",
    user_principal_name = "api_test@contoso.com",
    job_title = "Some Job",
    department = "Some Department",
    office_location = "job site",
    street_address = "street",
    city = "city",
    state = "state",
    country = "country",
    postal_code = "zip",
    password_profile = PasswordProfile(
        force_change_password_next_sign_in = True,
        password = "This is secure!",
    ),
)

async def create_user():
    ""
    results = await client.users.post(request_body)
    print(results)
    ""

asyncio.run(create_user())

input("Press ENTER to exit")