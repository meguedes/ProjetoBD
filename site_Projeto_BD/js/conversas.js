// ======================================================
// SISTEMA DE CONVERSAS - BANCO DE DADOS
// ======================================================


// Usuário logado
const usuario = JSON.parse(
    localStorage.getItem("usuarioLogado")
);


if (!usuario) {

    alert("Faça login para acessar suas conversas.");

    window.location.href = "/html/login.html";

}


// Elementos da página
const chatBox =
document.getElementById("chatBox");


const form =
document.getElementById("mensagemForm");


// Recupera o id da postagem vindo do feed
const parametros =
new URLSearchParams(window.location.search);


const idPost =
parametros.get("id_post");


console.log("ID POST RECEBIDO:", idPost);
console.log("USUARIO:", usuario);


// Guarda conversa atual
let idConversa = null;


// ======================================================
// CRIAR OU ABRIR CONVERSA
// ======================================================

async function iniciarConversa(){


    if(!idPost){

        const resposta = await fetch(
            `${API_BASE}/conversas/usuario/${usuario.cpf}`
        );


        const conversas =
        await resposta.json();


        chatBox.innerHTML = "";


        if(conversas.length === 0){

            chatBox.innerHTML = `

            <div class="chat-box-conversas text-muted mt-5">

                <h4>Nenhuma conversa encontrada</h4>

                <p>Quando alguém mandar mensagem aparecerá aqui.</p>

            </div>

            `;

            return;
        }


        conversas.forEach(conv=>{

            chatBox.innerHTML += `

            <div 
                class="chat-box-conversas"
                onclick="abrirConversa(${conv.id_conversa})">

                <strong>${conv.objeto}</strong>

                <br>

                Conversa com ${conv.usuario}

            </div>

            `;

        });


        return;
    }


    const resposta = await fetch(
        `${API_BASE}/conversas`,
        {

            method:"POST",

            headers:{
                "Content-Type":"application/json"
            },

            body:JSON.stringify({

                id_post:idPost,

                cpf:usuario.cpf

            })

        }
    );


    const dados =
    await resposta.json();


    console.log("CONVERSA:", dados);


    idConversa =
    dados.id_conversa;


    carregarMensagens();

}

// ======================================================
// ABRIR CONVERSA EXISTENTE
// ======================================================

function abrirConversa(id){

    idConversa = id;

    carregarMensagens();

}





// ======================================================
// CARREGAR MENSAGENS DO BANCO
// ======================================================

async function carregarMensagens(){


    const resposta =
    await fetch(
        `${API_BASE}/conversas/${idConversa}/mensagens`
    );


    const mensagens =
    await resposta.json();


    chatBox.innerHTML="";


    if(mensagens.length === 0){

        chatBox.innerHTML=`

        <div class="text-center text-muted mt-5">

            <h4>Nenhuma mensagem ainda</h4>

            <p>Envie a primeira mensagem.</p>

        </div>

        `;

        return;
    }


    mensagens.forEach(msg=>{


        const classe =
        msg.cpf_remetente === usuario.cpf
        ? "enviada"
        : "recebida";


        chatBox.innerHTML +=`

        <div class="mensagem ${classe}">

            <strong>
            ${msg.nome}
            </strong>

            <br>

            ${msg.conteudo}

        </div>

        `;

    });

    chatBox.scrollTop = chatBox.scrollHeight;


}



// ======================================================
// ENVIAR MENSAGEM
// ======================================================


form.addEventListener(
"submit",

async function(e){


    e.preventDefault();


    const campo =
    document.getElementById("mensagem");


    const texto =
    campo.value.trim();


    if(!texto){

        return;

    }


    console.log("ENVIANDO:", texto);


    const resposta =
    await fetch(
        `${API_BASE}/mensagens`,
        {

            method:"POST",

            headers:{
                "Content-Type":"application/json"
            },


            body:JSON.stringify({

                id_conversa:idConversa,

                cpf:usuario.cpf,

                texto:texto

            })

        }
    );


    if(!resposta.ok){

        alert("Erro ao enviar mensagem");

        return;

    }


    form.reset();


    carregarMensagens();


});



// inicia automaticamente
iniciarConversa();
