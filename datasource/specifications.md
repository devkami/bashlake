# Data Source Structure Especifications - JSON

## Overview

This README outlines the structure and usage of JSON configuration files for data sources in a data lake project. Each data source, whether a database or an API, is defined in a separate JSON file. These files detail the necessary parameters for connection and data extraction.

## Types of Data Sources

### Relational Database

A "Relational Database" data source typically involves structured data stored in tables. Authentication for these databases generally requires the following mandatory fields: `host`, `port`, `user`, `encryptedPassword`, and `database`. This setup ensures secure and specific access to the required database schemas and tables.

### APIs

"APIs" as data sources can vary significantly in structure and format. They may range from RESTful services to GraphQL APIs, each potentially having its own method of authentication. Common authentication methods include API keys, OAuth tokens, or even basic authentication with a username and password. Some APIs, particularly public APIs, might not require authentication at all. The specific endpoints and data formats depend on the API's design and purpose.

## File Structure

### Database Data Source Template

```json
{
  "source": {
    "title": "String - Descriptive title of the data source.",
    "description": "String - Short Description for the data source",
    "origin": "String - Name of the application that originally generated the data",
    "company":"String - Name of the company responsible for the data",
    "type": "Integer - Type of data source (1- Database, 2- API).",
    "auth": {
      "host": "String - Database server host.",
      "port": "Integer - Database server port.",
      "user": "String - Database user name.",
      "password": "String - Encrypted database password.",
      "database": "String - Database name."
    }
  },
  "schema": {
    "tables": "Array[String] - List of table names to extract.",
    "views": "Array[String] - List of view names to extract.",
    "routines": "Array[String] - List of routines names to extract.",    
    "events": "Array[String] - List of events names to extract."
  },
  "syncs":[
    {
      "frequency": "Integer - How often to update",
      "period": "String - Unit of time ('secs', 'mins', 'hours', 'days')",
      "targets": "JSON - Which parts of 'schema' with it's itens to update"
    }
  ]
}
```

### API Data Source Template

```json
{
  "source": {
    "title": "String - Descriptive title of the data source.",
    "type": "String - Type of data source (e.g., 'API').",
    "baseUrl": "String - Base URL to connect with API",
    "auth": {      
      "url": "String - API Atuhentication URL.",
      "apiKey": "String - Encrypted API key.",      
    }
  },
  "schema": {
    "endpoints": [
      {
        "endpoint": "String - Specific API endpoint.",
        "method": "String - HTTP method (e.g., 'GET').",
        "lookup_field": "String - Field to search for a especific record id",
        "fields": [          
          {
            "field": "String - Field Name",
            "type": "String - Field Data Type",
            "definitions": {              
              "sql": "SQL instruction for the field definition"
            }
          },          
        ]
      },
    ]
  },
  "syncs": [
    {
      "frequency": "Integer - How often to update",
      "period": "String - Unit of time ('secs', 'mins', 'hours', 'days')",
      "targets": "Array[String] - Which endpoints to update"
    }
  ]
}
```
