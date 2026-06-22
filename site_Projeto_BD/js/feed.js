// ======================================================
// SISTEMA DE ACHADOS E PERDIDOS - IMPACTO CIRCULAR
// ======================================================

// ------------------------------------------------------
// 1. MASSA DE DADOS
// ------------------------------------------------------
// Futuramente os dados poderão ser carregados do
// LocalStorage. Enquanto isso, utilizamos um vetor
// contendo exemplos de postagens para testes.

// const postagens = JSON.parse(
//     localStorage.getItem("postagens")
// ) || [];

postagens = [

    {
        nomeObjeto: "Notebook Dell",

        descricao:
        "Notebook encontrado próximo ao ICC Norte.",

        categoria: "Eletrônicos",

        cor: "Preto",

        tamanho: "Médio",

        localizacao:
        "Instituto Central de Ciências (ICC)",

        tipo_postagem: "Encontrado",

        status_postagem: "Aberto",

        data_hora:
        "21/06/2026 10:30",

        usuario:
        "Rafael Henrique",

        foto:
        "https://images.unsplash.com/photo-1496181133206-80ce9b88a853"
    },

    {
        nomeObjeto: "Mochila Adidas",

        descricao:
        "Perdida próxima à Biblioteca Central.",

        categoria: "Mochilas",

        cor: "Azul",

        tamanho: "Grande",

        localizacao:
        "Biblioteca Central (BCE)",

        tipo_postagem: "Perdido",

        status_postagem: "Aberto",

        data_hora:
        "20/06/2026 15:20",

        usuario:
        "Gabrielle",

        foto:
        "https://images.unsplash.com/photo-1581605405669-fcdf81165afa"
    }

];

// Exibe as postagens no console para fins de depuração
console.log(postagens);

// ------------------------------------------------------
// 2. REFERÊNCIAS AOS ELEMENTOS HTML
// ------------------------------------------------------

// Container onde as publicações serão exibidas
const container =
document.getElementById("container-feed");

// Recupera os dados do usuário autenticado
const usuarioLogado =
JSON.parse(
    localStorage.getItem("usuarioLogado")
);

// Área da barra de navegação destinada ao usuário
const areaUsuario =
document.getElementById("areaUsuario");

// ------------------------------------------------------
// 3. VERIFICAÇÃO DE LOGIN
// ------------------------------------------------------
// Caso exista um usuário logado, exibe o botão
// "Meu Perfil". Caso contrário, exibe "Entrar".

if(usuarioLogado){

    areaUsuario.innerHTML = `

        <a
            href="perfil.html"
            class="btn btn-premium">

            Meu Perfil

        </a>

    `;

}else{

    areaUsuario.innerHTML = `

        <a
            href="login.html"
            class="btn btn-premium">

            Entrar

        </a>

    `;

}

// ------------------------------------------------------
// 4. GERAÇÃO DINÂMICA DAS POSTAGENS
// ------------------------------------------------------
// Percorre todas as postagens e cria os cards
// dinamicamente no feed.

postagens.forEach(post => {

    // Define quais botões serão exibidos
    // dependendo do estado de autenticação.

    const botoesUsuario =
    usuarioLogado

    ? `
        <div class="mt-3">

            <a
                href="conversa.html"
                class="btn btn-premium">

                Conversar

            </a>

        </div>
    `

    : `
        <div class="mt-3">

            <a
                href="login.html"
                class="btn btn-premium">

                Entrar para entrar em contato

            </a>

        </div>
    `;

    // Criação do card da publicação

    container.innerHTML += `

    <div class="premium-card">

        <!-- Imagem do objeto -->
        <img
            src="${post.foto}"
            class="feed-img">

        <div class="card-overlay">

            <!-- Tipo da postagem -->
            <div>

                <span class="glass-badge">

                    ${post.tipo_postagem}

                </span>

            </div>

            <!-- Informações da postagem -->
            <div>

                <h2 class="card-title">

                    ${post.nomeObjeto}

                </h2>

                <p class="card-desc">

                    ${post.descricao}

                </p>

                <p>📍 ${post.localizacao}</p>

                <p>🏷️ ${post.categoria}</p>

                <p>🎨 ${post.cor}</p>

                <p>📏 ${post.tamanho}</p>

                <p>📅 ${post.data_hora}</p>

                <p>👤 ${post.usuario}</p>

                <p>🟢 ${post.status_postagem}</p>

                ${botoesUsuario}

            </div>

        </div>

    </div>

    `;

});

// ------------------------------------------------------
// 5. FUNÇÃO DE DEFINIÇÃO DE CORES POR STATUS
// ------------------------------------------------------
// Retorna uma cor associada ao estado atual da
// postagem. Pode ser utilizada para estilizar
// indicadores visuais de situação.

function corStatus(status){

    switch(status){

        case "Aberto":
            return "green";

        case "Em contato":
            return "orange";

        case "Resolvido":
            return "blue";

        case "Devolvido":
            return "purple";

        default:
            return "gray";
    }
}