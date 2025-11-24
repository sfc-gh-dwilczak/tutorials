async function sendMessage() {
    const input = document.getElementById('chat-input');
    const chatBox = document.getElementById('chat-box');
    const message = input.value.trim();
    if (!message) return;
  
    // Show user message
    chatBox.innerHTML += `
      <div class="flex justify-end mb-2">
        <div class="bg-indigo-600 text-white p-3 rounded-lg max-w-3/4 whitespace-pre-wrap">
          ${message}
        </div>
      </div>`;
    input.value = '';
    chatBox.scrollTop = chatBox.scrollHeight;
  
    // Get selected model
    const selectedModel = document.querySelector('input[name="semantic-model"]:checked')?.value || 'sales.yaml';
  
    // Send to backend
    const response = await fetch('/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt: message, model: selectedModel })
    });
  
    const data = await response.json();
    let botMessage = '';
  
    if (data.response?.error) {
      botMessage = `<span class="text-red-400">${data.response.error}</span>`;
    } else {
      data.response.message.content.forEach(item => {
        if (item.type === "text") {
          botMessage += `<p>${item.text}</p>`;
        }
      });
  
      if (data.sql_results?.length) {
        let table = '<div class="overflow-auto mt-2"><table class="table-auto w-full border border-gray-600">';
        table += '<thead><tr>';
        data.sql_columns.forEach(col => {
          table += `<th class="px-3 py-1 bg-gray-800 border border-gray-700">${col}</th>`;
        });
        table += '</tr></thead><tbody>';
        data.sql_results.forEach(row => {
          table += '<tr>';
          data.sql_columns.forEach(col => {
            table += `<td class="px-3 py-1 border border-gray-700">${row[col]}</td>`;
          });
          table += '</tr>';
        });
        table += '</tbody></table></div>';
        botMessage += table;
      }
    }
  
    chatBox.innerHTML += `
      <div class="flex justify-start mb-2">
        <div class="bg-gray-700 text-gray-200 p-3 rounded-lg max-w-3/4 whitespace-pre-wrap">
          ${botMessage}
        </div>
      </div>`;
    chatBox.scrollTop = chatBox.scrollHeight;
  }
  
  document.getElementById('chat-input').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') sendMessage();
  });
  