// ======================================================
// MINHAS POSTAGENS
// ======================================================

// Recupera o usuário logado
const usuarioLogado = JSON.parse(
    localStorage.getItem("usuarioLogado")
);

// Container da página
const container =
document.getElementById("listaPostagens");

if(!usuarioLogado){

    alert("Faça login primeiro!");

    window.location.href = "/html/login.html";

}

// ======================================================
// CARREGA AS POSTAGENS DO USUÁRIO LOGADO (via API)
// ======================================================

async function carregarPostagens(){

    const resposta = await fetch(
        `${API_BASE}/postagens?cpf=${encodeURIComponent(usuarioLogado.cpf)}`
    );

    const postagens = await resposta.json();

    // Caso não existam postagens
    if(postagens.length === 0){

        container.innerHTML = `

            <div class="alert alert-info">

                Você ainda não possui publicações.

            </div>

        `;

        return;
    }

    container.innerHTML = "";

    // Exibe as postagens
    postagens.forEach(post => {

        const classeStatus =

            post.status_postagem === "Aberto" || post.status_postagem === "Aberta"

            ? "status-aberto"

            : "status-resolvido";

        container.innerHTML += `

        <div class="postagem-card">

            <h4>${post.nomeObjeto}</h4>

            <p>
                📍 ${post.localizacao}
            </p>

            <p class="postagem-data">
                📅 ${post.data_hora}
            </p>

            <p class="${classeStatus}">
                ${post.status_postagem}
            </p>

            <a
                href="/html/conversas.html"
                class="btn btn-primary">

                Ver Conversas

            </a>

            <button
                class="btn btn-success ms-2"
                onclick="marcarDevolvido(${post.id_post})">

                Marcar como Devolvido

            </button>

            <button
                class="btn btn-danger ms-2"
                onclick="excluirPostagem(${post.id_post})">

                Excluir

            </button>

        </div>

        `;

    });

}

carregarPostagens();

// ======================================================
// MARCAR COMO DEVOLVIDO
// ======================================================

async function marcarDevolvido(idPost){

    const resposta = await fetch(
        `${API_BASE}/postagens/${idPost}/devolver`,
        {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ cpf: usuarioLogado.cpf })
        }
    );

    if(!resposta.ok){
        const dados = await resposta.json();
        alert(dados.erro || "Não foi possível marcar como devolvido.");
        return;
    }

    location.reload();
}

// ======================================================
// EXCLUIR POSTAGEM
// ======================================================

async function excluirPostagem(idPost){

    const confirmar = confirm(
        "Deseja realmente excluir esta publicação?"
    );

    if(!confirmar){
        return;
    }

    const resposta = await fetch(
        `${API_BASE}/postagens/${idPost}?cpf=${encodeURIComponent(usuarioLogado.cpf)}`,
        { method: "DELETE" }
    );

    if(!resposta.ok){
        const dados = await resposta.json();
        alert(dados.erro || "Não foi possível excluir a publicação.");
        return;
    }

    alert("Publicação excluída com sucesso!");

    location.reload();
}
