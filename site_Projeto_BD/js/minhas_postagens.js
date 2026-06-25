// ======================================================
// MINHAS POSTAGENS
// ======================================================

// Recupera as postagens salvas
let postagens = JSON.parse(
    localStorage.getItem("postagens")
) || [];

// Container da página
const container =
document.getElementById("listaPostagens");

// Caso não existam postagens
if(postagens.length === 0){

    container.innerHTML = `

        <div class="alert alert-info">

            Você ainda não possui publicações.

        </div>

    `;

}

// Exibe as postagens
postagens.forEach((post, index) => {

    const classeStatus =

        post.status_postagem === "Aberto"

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
            onclick="marcarDevolvido(${index})">

            Marcar como Devolvido

        </button>

        <button
            class="btn btn-danger ms-2"
            onclick="excluirPostagem(${index})">

            Excluir

        </button>

    </div>

    `;

});

// ======================================================
// MARCAR COMO DEVOLVIDO
// ======================================================

function marcarDevolvido(index){

    let postagens = JSON.parse(
        localStorage.getItem("postagens")
    ) || [];

    postagens[index].status_postagem =
    "Devolvido";

    localStorage.setItem(
        "postagens",
        JSON.stringify(postagens)
    );

    location.reload();
}

// ======================================================
// EXCLUIR POSTAGEM
// ======================================================

function excluirPostagem(index){

    const confirmar = confirm(
        "Deseja realmente excluir esta publicação?"
    );

    if(!confirmar){
        return;
    }

    let postagens = JSON.parse(
        localStorage.getItem("postagens")
    ) || [];

    postagens.splice(index, 1);

    localStorage.setItem(
        "postagens",
        JSON.stringify(postagens)
    );

    alert("Publicação excluída com sucesso!");

    location.reload();
}