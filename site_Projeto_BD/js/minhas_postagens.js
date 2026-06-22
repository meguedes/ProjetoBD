// ======================================================
// SISTEMA UNB - ACHADOS E PERDIDOS
// Página de Gerenciamento de Postagens
// ======================================================

// ------------------------------------------------------
// 1. MASSA DE DADOS
// ------------------------------------------------------
// Vetor contendo exemplos de publicações cadastradas
// pelo usuário. Cada objeto representa um item
// perdido ou encontrado.

const postagens = [

{
    objeto: "Notebook Dell",

    local: "Biblioteca Central",

    data: "21/06/2026 19:20",

    status: "Aberto"
},

{
    objeto: "Mochila Azul",

    local: "ICC Sul",

    data: "20/06/2026 08:15",

    status: "Resolvido"
},

{
    objeto: "Garrafa Stanley",

    local: "FT",

    data: "19/06/2026 17:40",

    status: "Aberto"
}

];

// ------------------------------------------------------
// 2. REFERÊNCIA AO ELEMENTO HTML
// ------------------------------------------------------
// Container onde as postagens serão exibidas.

const container =
document.getElementById("listaPostagens");

// ------------------------------------------------------
// 3. GERAÇÃO DINÂMICA DAS POSTAGENS
// ------------------------------------------------------
// Percorre o vetor de postagens e cria os cards
// dinamicamente na página.

postagens.forEach(post => {

    // Define a classe CSS do status
    // de acordo com a situação da postagem.

    const classeStatus =

        post.status === "Aberto"

        ? "status-aberto"

        : "status-resolvido";

    // Adiciona o card da postagem ao container.

    container.innerHTML += `

    <div class="postagem-card">

        <!-- Nome do objeto -->
        <h4>${post.objeto}</h4>

        <!-- Local onde o objeto foi encontrado ou perdido -->
        <p>
            📍 ${post.local}
        </p>

        <!-- Data da publicação -->
        <p class="postagem-data">
            📅 ${post.data}
        </p>

        <!-- Status atual da postagem -->
        <p class="${classeStatus}">
            ${post.status}
        </p>

        <!-- Botão para acessar conversas relacionadas -->
        <a
            href="conversa.html"
            class="btn btn-primary">

            Ver Conversas

        </a>

        <!-- Botão para atualizar o status do objeto -->
        <button
            class="btn btn-success ms-2">

            Marcar como Devolvido

        </button>

    </div>

    `;

});

// ------------------------------------------------------
// FUNCIONAMENTO DO SISTEMA
// ------------------------------------------------------
// 1. O vetor "postagens" armazena os dados das publicações.
// 2. O elemento "listaPostagens" recebe os cards gerados.
// 3. O método forEach percorre todas as postagens.
// 4. Para cada item é criado um card contendo:
//      - Nome do objeto
//      - Localização
//      - Data
//      - Status
//      - Botão para visualizar conversas
//      - Botão para marcar devolução
// 5. A classe CSS do status muda automaticamente
//    conforme o valor armazenado na postagem.
//
// Exemplo:
// "Aberto"    -> status-aberto
// "Resolvido" -> status-resolvido
//
// Isso permite aplicar estilos visuais diferentes
// para cada situação da publicação.
// ------------------------------------------------------