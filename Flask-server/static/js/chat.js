window.onload = function() {
    displayStoredConv();
}

function displayStoredConv() {
    const storedConv = JSON.parse(localStorage.getItem('data')) || [];
    const chatDiv = document.getElementById('chat');

    storedConv.forEach(message => {
        if (message.role === 'user') {
            chatDiv.innerHTML += `<div class="user"><p>${message.content}</p></div>`;
        } else if (message.role === 'assistant') {
            if (message.thinkingTime !== null) {
                chatDiv.innerHTML += `
                  <div class="thinking">
                    <p>Tänkte i ${message.thinkingTime} sekunder…</p>
                  </div>`;
              }
              chatDiv.innerHTML += `<div class="ai"><p>${message.content}</p></div>`;
        }
    });
}

function save_msg(role, content, thinkingTime) {
    const messages = JSON.parse(localStorage.getItem('data')) || [];
    messages.push({ role, content, thinkingTime });
    localStorage.setItem('data', JSON.stringify(messages));
}

function send(){
    const user_input = document.getElementById("input").value;
    const chatDiv = document.getElementById("chat");

    if (user_input === '') return;

    chatDiv.innerHTML += `<div class="user"><p>${user_input}</p></div>`;
    scrollToBottom();

    const startTime = Date.now();

    fetch('/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ 'text-input': user_input })
    })
    .then(respons => {
        if (!respons.ok) throw new Error('Server error');
        return respons.text();
    })
    .then(data => {

        const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);


        chatDiv.innerHTML += `
          <div class="thinking">
            <p>Tänkte i ${elapsed} sekunder…</p>
          </div>`;

        const ai_msg = marked.parse(data);
        chatDiv.innerHTML += `<div class="ai"><p>${ai_msg}</p></div>`;


        save_msg('user', user_input);
        save_msg('assistant', ai_msg, elapsed);

        scrollToBottom();
    })
    .catch(error => {
        console.error('Error:', error);
    })
    .finally(() => {
        document.getElementById('input').value = '';
    });
}
const scrollToBottom = () => {
    const chat = document.getElementById('chat');
    if (chat) {
        chat.scrollTop = chat.scrollHeight;
    }
}