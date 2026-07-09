
// ======================================================
// SISTEMA UNB - ACHADOS E PERDIDOS
// Página Inicial (Feed)
// ======================================================

// ------------------------------------------------------
// 1. CARREGAMENTO DAS POSTAGENS
// ------------------------------------------------------
// Recupera todas as postagens diretamente da API,
// que consulta a view vw_feed_completo no PostgreSQL.

async function buscarPostagens(){
    const resposta = await fetch(`${API_BASE}/postagens`);
    return resposta.json();
}

// ------------------------------------------------------
// 2. REFERÊNCIAS AOS ELEMENTOS HTML
// ------------------------------------------------------

const container =
document.getElementById("container-feed");

const usuarioLogado =
JSON.parse(
    localStorage.getItem("usuarioLogado")
);

const areaUsuario =
document.getElementById("areaUsuario");

// ------------------------------------------------------
// 3. VERIFICAÇÃO DE LOGIN
// ------------------------------------------------------
// Exibe "Meu Perfil" quando existe um usuário
// autenticado. Caso contrário, exibe o botão
// para realizar login.

if(areaUsuario){

    if(usuarioLogado){

        areaUsuario.innerHTML = `

            <a
                href="/html/perfil.html"
                class="btn btn-premium">

                Meu Perfil

            </a>

        `;

    }else{

        areaUsuario.innerHTML = `

            <a
                href="/html/login.html"
                class="btn btn-premium">

                Entrar

            </a>

        `;

    }

}

// ------------------------------------------------------
// 4. DEFINE A COR DO STATUS
// ------------------------------------------------------

function corStatus(status){

    switch(status){

        case "Aberto":
        case "Aberta":
            return "limegreen";

        case "Em contato":
            return "orange";

        case "Resolvido":
            return "deepskyblue";

        case "Devolvido":
            return "violet";

        default:
            return "gray";

    }

}

// ------------------------------------------------------
// 5. RENDERIZAÇÃO DO FEED
// ------------------------------------------------------

async function renderizarFeed(){

const postagens = await buscarPostagens();

if(postagens.length === 0){

    container.innerHTML = `

        <div class="text-center py-5">

            <h3>

                📦 Nenhuma publicação encontrada

            </h3>

            <p class="text-light">

                Ainda não existem objetos cadastrados.

            </p>

            <a
                href="/html/cadastro_objeto.html"
                class="btn btn-premium">

                Publicar objeto

            </a>

        </div>

    `;

}else{

    // --------------------------------------------------
    // 6. GERAÇÃO DOS CARDS
    // --------------------------------------------------

    postagens.forEach(post =>{
        console.log("POST:", post);
        console.log("LINK:", `/html/conversas.html?id_post=${post.id_post}`);

        let botoesUsuario;

        // ----------------------------------------------
        // Usuário não autenticado
        // ----------------------------------------------

        if(!usuarioLogado){

            botoesUsuario = `

                <div class="mt-3">

                    <a
                        href="/html/login.html"
                        class="btn btn-premium">

                        Entrar para entrar em contato

                    </a>

                </div>

            `;

        // ----------------------------------------------
        // Publicação do próprio usuário
        // ----------------------------------------------

        }else if(post.cpf === usuarioLogado.cpf){

            botoesUsuario = `

                <div class="mt-3">

                    <a
                        href="/html/minhas_postagens.html"
                        class="btn btn-premium">

                        Gerenciar publicação

                    </a>

                </div>

            `;

        // ----------------------------------------------
        // Publicação de outro usuário
        // ----------------------------------------------

        }else{

            const linkConversa =
            `/html/conversas.html?id_post=${post.id_post}`;


            botoesUsuario = `

                <div class="mt-3">

                    <a
                        href="${linkConversa}"
                        class="btn btn-premium">

                        Conversar

                    </a>

                </div>

            `;


            console.log("BOTÃO CRIADO:", linkConversa);

        }

        // ----------------------------------------------
        // Criação do card da postagem
        // ----------------------------------------------

        container.innerHTML += `

            <div class="premium-card">

                <img
                    src="${post.foto}"
                    class="feed-img"
                    alt="${post.nomeObjeto}">

                <div class="card-overlay">

                    <div>

                        <span class="glass-badge">

                            ${post.tipo_postagem}

                        </span>

                    </div>

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

                        <p
                            style="
                                color:${corStatus(post.status_postagem)};
                                font-weight:bold;
                            ">

                            ● ${post.status_postagem}

                        </p>

                        ${botoesUsuario}

                    </div>

                </div>

            </div>

        `;

    });

}

}

renderizarFeed();

// ------------------------------------------------------
// FUNCIONAMENTO DO SISTEMA
// ------------------------------------------------------
//
// 1. Recupera as postagens do LocalStorage.
//
// 2. Verifica se existe um usuário autenticado.
//
// 3. Caso não existam publicações,
//    é exibida uma mensagem informativa.
//
// 4. Para cada postagem é criado um card
//    contendo:
//
//      - Foto;
//      - Tipo da postagem;
//      - Nome do objeto;
//      - Descrição;
//      - Localização;
//      - Categoria;
//      - Cor;
//      - Tamanho;
//      - Data;
//      - Nome do responsável;
//      - Status.
//
// 5. Os botões variam conforme a situação:
//
//      • Não autenticado:
//        "Entrar para entrar em contato"
//
//      • Dono da publicação:
//        "Gerenciar publicação"
//
//      • Outro usuário:
//        "Conversar"
//
// Futuramente as publicações serão carregadas
// diretamente do PostgreSQL através do Flask.
// ------------------------------------------------------