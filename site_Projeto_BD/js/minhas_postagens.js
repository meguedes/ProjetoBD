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

// Guarda a última lista carregada, para preencher o
// formulário de edição sem precisar de uma nova requisição
let postagensAtuais = [];

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

    postagensAtuais = postagens;

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

        <div class="postagem-card" id="card-${post.id_post}">

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
                class="btn btn-warning ms-2"
                onclick="editarPostagem(${post.id_post})">

                Editar

            </button>

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

    try {

        const resposta = await fetch(
            `${API_BASE}/postagens/${idPost}?cpf=${encodeURIComponent(usuarioLogado.cpf)}`,
            { method: "DELETE" }
        );

        if(!resposta.ok){
            // Ex: 409 quando existe Devolucao vinculada (conflito de FK)
            const dados = await resposta.json();
            alert(dados.erro || "Não foi possível excluir a publicação.");
            return;
        }

        alert("Publicação excluída com sucesso!");

        location.reload();

    } catch(erro){

        alert("Não foi possível conectar ao servidor. Verifique se a API está rodando.");

    }
}

// ======================================================
// EDITAR POSTAGEM
// ======================================================

function editarPostagem(idPost){

    const post = postagensAtuais.find(p => p.id_post === idPost);

    if(!post){
        return;
    }

    const card = document.getElementById(`card-${idPost}`);

    card.innerHTML = `

        <div class="mb-2">
            <label class="form-label">Nome do objeto</label>
            <input type="text" class="form-control" id="edit-nome-${idPost}" value="${post.nomeObjeto ?? ""}">
        </div>

        <div class="mb-2">
            <label class="form-label">Cor</label>
            <input type="text" class="form-control" id="edit-cor-${idPost}" value="${post.cor ?? ""}">
        </div>

        <div class="mb-2">
            <label class="form-label">Tamanho</label>
            <input type="text" class="form-control" id="edit-tamanho-${idPost}" value="${post.tamanho ?? ""}">
        </div>

        <div class="mb-3">
            <label class="form-label">Descrição</label>
            <textarea class="form-control" id="edit-descricao-${idPost}">${post.descricao ?? ""}</textarea>
        </div>

        <button class="btn btn-success" onclick="salvarEdicaoPostagem(${idPost})">
            Salvar
        </button>

        <button class="btn btn-secondary ms-2" onclick="carregarPostagens()">
            Cancelar
        </button>

    `;
}

async function salvarEdicaoPostagem(idPost){

    const corpo = {
        cpf: usuarioLogado.cpf,
        nome_objeto: document.getElementById(`edit-nome-${idPost}`).value,
        cor: document.getElementById(`edit-cor-${idPost}`).value,
        tamanho: document.getElementById(`edit-tamanho-${idPost}`).value,
        descricao: document.getElementById(`edit-descricao-${idPost}`).value,
    };

    if(!corpo.nome_objeto){
        alert("O nome do objeto não pode ficar vazio.");
        return;
    }

    try {

        const resposta = await fetch(
            `${API_BASE}/postagens/${idPost}`,
            {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(corpo)
            }
        );

        if(!resposta.ok){
            const dados = await resposta.json();
            alert(dados.erro || "Não foi possível salvar a edição.");
            return;
        }

        alert("Postagem atualizada com sucesso!");

        carregarPostagens();

    } catch(erro){

        alert("Não foi possível conectar ao servidor. Verifique se a API está rodando.");

    }
}
