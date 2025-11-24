from flask import Flask, render_template, request, jsonify
import requests
import snowflake.connector
import pandas as pd
import warnings
import logging

warnings.filterwarnings("ignore", message="pandas only supports SQLAlchemy")

app = Flask(__name__)

DATABASE = "RAW"
SCHEMA = "CORTEX"
STAGE = "FILES"
WAREHOUSE = "DEVELOPMENT"

# If your snowflake account has an underscore then you must use the account locator here for host.
HOST = "<Account Identifier>"
ACCOUNT = "<Account Identifier>"
USER = "<Username>"
PASSWORD = "<Password>"
ROLE = "<role>"

conn = snowflake.connector.connect(
    user=USER,
    password=PASSWORD,
    account=ACCOUNT,
    warehouse=WAREHOUSE,
    role=ROLE,
)

@app.route('/')
def index():
    semantic_models = [
        {"name": "Sales", "file": "sales.yaml", "avatar": "img/avatars/avatar-5.jpg"},
        {"name": "Marketing", "file": "marketing.yaml", "avatar": "img/avatars/avatar-2.jpg"},
        {"name": "Support", "file": "support.yaml", "avatar": "img/avatars/avatar-3.jpg"},
    ]

    active_model = request.args.get("model", "sales.yaml")

    return render_template("index.html", semantic_models=semantic_models, active_model=active_model)

@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    prompt = data.get("prompt")
    file = data.get("model", "sales.yaml")  # Dynamic model file

    if not file.endswith(".yaml"):
        return jsonify({"error": "Invalid model file"}), 400

    request_body = {
        "messages": [{"role": "user", "content": [{"type": "text", "text": prompt}]}],
        "semantic_model_file": f"@{DATABASE}.{SCHEMA}.{STAGE}/{file}",
    }

    headers = {
        "Authorization": f'Snowflake Token="{conn.rest.token}"',
        "Content-Type": "application/json",
    }

    resp = requests.post(
        f"https://{HOST}/api/v2/cortex/analyst/message",
        json=request_body,
        headers=headers,
    )

    if resp.status_code != 200:
        logging.error("Cortex error: %s", resp.text)
        return jsonify({"error": "Cortex API failed", "details": resp.text}), resp.status_code

    cortex_response = resp.json()

    sql_results, sql_columns = [], []
    for item in cortex_response["message"].get("content", []):
        if item["type"] == "sql":
            try:
                df = pd.read_sql(item["statement"], conn)
                sql_results = df.to_dict(orient="records")
                sql_columns = df.columns.tolist()
            except Exception as e:
                logging.warning("SQL execution error: %s", str(e))

    return jsonify({
        "response": cortex_response,
        "sql_results": sql_results,
        "sql_columns": sql_columns,
        "model_used": file
    })

if __name__ == '__main__':
    app.run(debug=True)
