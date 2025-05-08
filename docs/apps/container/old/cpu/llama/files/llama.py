from flask import Flask, request, jsonify, make_response
from llama_cpp import Llama

# Initialize Flask app with a name.
app = Flask("Llama server")
# Initialize the model as None to load it lazily.
model = None

@app.post('/llama')
def generate_response():
    # Extract the 'data' from the JSON body of the request.
    input_rows = request.json['data']
    # Generate output rows by iterating over input rows, calling llm function for each, and combining the result.
    output_rows = [[row[0], llm(row[1], row[2], row[3])] for row in input_rows]
    # Create and return a JSON response with the output data, status code 200, and content type set to JSON.
    return make_response(jsonify({"data": output_rows}), 200, {'Content-Type': 'application/json'})

def llm(system_message, user_message, max_tokens):
    # Reference the global model variable to modify it inside the function.
    global model
    # Format the prompt string required by the model.
    prompt = f"<s>[INST] <<SYS>> {system_message} <</SYS>> {user_message} [/INST]"
    # Check if model is not loaded.
    if model is None:
        # Lazy loading of the model on the first request.
        model = Llama(model_path="./llama-2-7b-chat.Q2_K.gguf")
    # Call the model with the formatted prompt and extract text after the instruction using a helper function.
    return extract_text_after_inst(model(prompt, max_tokens=max_tokens, echo=True))

def extract_text_after_inst(data):
    # Extract the generated text from the model's output.
    text = data["choices"][0]["text"]
    # Find the end position of the instruction marker.
    inst_end_pos = text.find("[/INST]")
    # Extract and return the text after "[/INST]" marker if found, otherwise return an empty string.
    return text[inst_end_pos + len("[/INST]"):].strip() if inst_end_pos != -1 else ""

if __name__ == '__main__':
    # Start the Flask application on port 8080 accessible from any host.
    app.run(host='0.0.0.0', port=8080)