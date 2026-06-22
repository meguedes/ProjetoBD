// Vetor que armazena as mensagens iniciais do chat
const mensagens = [

{
    usuario: "Rafael",
    texto: "Olá! Acho que encontrei seu notebook.",
    tipo: "recebida" // Mensagem recebida de outro usuário
},

{
    usuario: "Você",
    texto: "Sério? Onde ele está?",
    tipo: "enviada" // Mensagem enviada pelo usuário
}

];

// Obtém a referência da área onde as mensagens serão exibidas
const chatBox = document.getElementById("chatBox");

/**
 * Função responsável por carregar e exibir todas as mensagens
 * armazenadas no vetor "mensagens".
 */
function carregarMensagens() {

    // Limpa o conteúdo atual do chat antes de recarregar as mensagens
    chatBox.innerHTML = "";

    // Percorre todas as mensagens do vetor
    mensagens.forEach(msg => {

        // Adiciona cada mensagem ao conteúdo HTML do chat
        chatBox.innerHTML += `

        <div class="mensagem ${msg.tipo}">

            <strong>${msg.usuario}</strong>

            <br>

            ${msg.texto}

        </div>

        `;

    });

}

// Exibe as mensagens iniciais quando a página é carregada
carregarMensagens();

// Obtém a referência do formulário de envio de mensagens
const form = document.getElementById("mensagemForm");

/**
 * Evento executado quando o formulário é enviado.
 * Adiciona uma nova mensagem ao vetor e atualiza o chat.
 */
form.addEventListener("submit", function(e) {

    // Impede o comportamento padrão do formulário
    // (recarregar a página)
    e.preventDefault();

    // Captura o texto digitado pelo usuário
    const texto = document.getElementById("mensagem").value;

    // Adiciona a nova mensagem ao vetor
    mensagens.push({

        usuario: "Você",

        texto: texto,

        tipo: "enviada"

    });

    // Atualiza a exibição das mensagens no chat
    carregarMensagens();

    // Limpa o campo de texto do formulário
    form.reset();

});