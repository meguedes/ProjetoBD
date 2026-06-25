
//autenticação do usuario
const usuario = JSON.parse(
    localStorage.getItem("usuarioLogado")
);

if (!usuario) {

    alert("Faça login para acessar suas conversas.");

    window.location.href = "/html/login.html";

}

// Vetor que armazena as mensagens iniciais do chat
const mensagens = [];

// Obtém a referência da área onde as mensagens serão exibidas
const chatBox = document.getElementById("chatBox");

/**
 * Função responsável por carregar e exibir todas as mensagens
 * armazenadas no vetor "mensagens".
 */
function carregarMensagens(){

    chatBox.innerHTML = "";

    if(mensagens.length === 0){

        chatBox.innerHTML = `

            <div class="text-center text-muted mt-5">

                <h4>

                    Nenhuma conversa encontrada

                </h4>

                <p>

                    Quando alguém entrar em contato
                    sobre um objeto publicado,
                    a conversa aparecerá aqui.

                </p>

            </div>

        `;

        return;
    }

    mensagens.forEach(msg=>{

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