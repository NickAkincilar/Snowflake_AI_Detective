-- Prerequisite: Goto Marketplace as AccountAdmin, Search for "Snowflake Docs" and GET the free snowflake-snowflake-documentation service on to yoru accout
-- This is the marketpalce URL to get the service:
-- https://app.snowflake.com/marketplace/listing/GZSTZ67BY9OQ4/snowflake-snowflake-documentation


use role accountadmin;


CREATE DATABASE IF NOT EXISTS SF_AI_DEMO;
CREATE SCHEMA IF NOT EXISTS SF_AI_DEMO.DEMO_SCHEMA;

CREATE ROLE  IF NOT EXISTS SF_INTELLIGENCE_DEMO;


USE SCHEMA SF_AI_DEMO.DEMO_SCHEMA;


CREATE OR REPLACE PROCEDURE SF_AI_DEMO.DEMO_SCHEMA.EXECUTE_DYNAMIC_SELECT(SQL_QUERY VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS
$$
  var query = SQL_QUERY.trim().toUpperCase();
  var allowedCommands = ['SELECT', 'SHOW', 'DESC', 'DESCRIBE'];
  var blockedCommands = ['ALTER', 'DROP', 'DELETE', 'UPDATE', 'INSERT', 'CREATE', 'TRUNCATE', 'MERGE'];
  
  var firstWord = query.split(/\s+/)[0];
  
  for (var i = 0; i < blockedCommands.length; i++) {
    if (query.includes(blockedCommands[i])) {
      throw new Error('Blocked command found: ' + blockedCommands[i] + '. Only SELECT, SHOW, DESC, and DESCRIBE queries are allowed.');
    }
  }
  
  if (!allowedCommands.includes(firstWord)) {
    throw new Error('Invalid command: ' + firstWord + '. Only SELECT, SHOW, DESC, and DESCRIBE queries are allowed.');
  }
  
  var stmt = snowflake.createStatement({sqlText: SQL_QUERY});
  var result = stmt.execute();
  var rows = [];
  
  while (result.next()) {
    var row = {};
    for (var i = 1; i <= result.getColumnCount(); i++) {
      row[result.getColumnName(i)] = result.getColumnValue(i);
    }
    rows.push(row);
  }
  
  return JSON.stringify(rows);
$$;


CREATE OR REPLACE AGENT SF_AI_DEMO.DEMO_SCHEMA.SNOWFLAKE_DETECTIVE
  COMMENT = 'This agent helps with Your Snowflake Accountrelated tasks'
  PROFILE = '{"display_name":"Snowflake Detective Agent for Account specific Performance, Cost & Config questions"}'
  FROM SPECIFICATION
  $$
  {
    "models": {
      "orchestration": "auto"
    },
    "orchestration": {},
    "instructions": {
      "orchestration": "You are technical help agent with access to Snowflake documentation. Always leverage Snowflake doc search to find most recent features and updates before providing an answer."
    },
    "tools": [
      {
        "tool_spec": {
          "type": "cortex_search",
          "name": "Snowflake_Documentation_Search",
          "description": "This tools provides latest Snowflake documentation, Knowledge Source & Sample code to help with Snowflake related technical questions."
        }
      },
      {
        "tool_spec": {
          "type": "generic",
          "name": "Execute_Dynamic_SQL",
          "description": "This tool allows agent to run SELECT, SHOW & DESCRIBE queries to collect information about the current Snowflake account, databases, tables, Views & etc.\n\n",
          "input_schema": {
            "type": "object",
            "properties": {
              "sql_query": {
                "description": "This should be a Snowflake specific SELECT, SHOW & DESCRIBE query to execute and it will return results. Make sure to properly escape single quotes are this is a SQL stored proc input param",
                "type": "string"
              }
            },
            "required": ["sql_query"]
          }
        }
      }
    ],
    "tool_resources": {
      "Execute_Dynamic_SQL": {
        "execution_environment": {
          "query_timeout": 15,
          "type": "warehouse",
          "warehouse": ""
        },
        "identifier": "SF_AI_DEMO.DEMO_SCHEMA.EXECUTE_DYNAMIC_SELECT",
        "name": "EXECUTE_DYNAMIC_SELECT(VARCHAR)",
        "type": "procedure"
      },
      "Snowflake_Documentation_Search": {
        "id_column": "SOURCE_URL",
        "max_results": 4,
        "search_service": "SNOWFLAKE_DOCUMENTATION.SHARED.CKE_SNOWFLAKE_DOCS_SERVICE",
        "title_column": "DOCUMENT_TITLE"
      }
    }
  }
  $$;


GRANT USAGE ON DATABASE SF_AI_DEMO TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SCHEMA SF_AI_DEMO.DEMO_SCHEMA TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON PROCEDURE SF_AI_DEMO.DEMO_SCHEMA.EXECUTE_DYNAMIC_SELECT(varchar) TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON AGENT SF_AI_DEMO.DEMO_SCHEMA.SNOWFLAKE_DETECTIVE TO ROLE SF_INTELLIGENCE_DEMO;

ALTER SNOWFLAKE INTELLIGENCE IF EXISTS 'SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT ADD AGENT SF_AI_DEMO.DEMO_SCHEMA.SNOWFLAKE_DETECTIVE;




  
