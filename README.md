# Snowflake_AI_Detective
Snowflake Intelligence Agent that can answer Account specific  performance, cost, optimization, config/setup and architectural related questions.

## Prerequisite: 
- Browse Marketplace as AccountAdmin then Search for "Snowflake Docs" and GET the free snowflake-snowflake-documentation service on to your account using default options
- This is the marketpalce URL to get the service: https://app.snowflake.com/marketplace/listing/GZSTZ67BY9OQ4/snowflake-snowflake-documentation

  

Run the SnowflakeDetective.sql script to configure the agent.

Creates a Snowflake Intelligence agent with access to 2 tools:
1. Cortex Search Service provided by Snowflake via the Marketplace which has the up to date vectorized index of Snowflake Documentation site. It allow the agent to research the latest info on both new or existing features.
2. Custom Tool: Stored Proc writted in JS that allows agent to execute SELECT, DESC, SHOW type queries on your account to gather information that it needs.
