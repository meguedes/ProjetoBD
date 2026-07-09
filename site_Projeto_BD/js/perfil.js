// ======================================================
// SISTEMA UNB - ACHADOS E PERDIDOS
// Página de Perfil
// ======================================================


// Usuário logado

const usuario =
JSON.parse(
    localStorage.getItem("usuarioLogado")
);


if(!usuario){

    alert("Faça login primeiro!");

    window.location.href =
    "/html/login.html";

}else{

    preencherPerfil();

}


// ======================================================
// MOSTRAR DADOS DO PERFIL
// ======================================================


function preencherPerfil(){


    document.getElementById("nomeUsuario").textContent =
    usuario.nome;


    document.getElementById("cpfUsuario").textContent =
    usuario.cpf;


    document.getElementById("emailUsuario").textContent =
    usuario.email;


    document.getElementById("telefoneUsuario").textContent =
    usuario.telefone;


    document.getElementById("registroUsuario").textContent =
    usuario.registro;


    document.getElementById("tipoUsuario").textContent =
    usuario.tipoUsuario;


}



// ======================================================
// EDITAR PERFIL
// ======================================================


document
.getElementById("btnEditarPerfil")
.addEventListener("click", function(){


const form =
document.getElementById("formPerfil");


document.getElementById("dadosPerfil")
.style.display =
"none";


form.innerHTML = `


<div class="mb-2">

<label>CPF</label>

<input
class="form-control"
value="${usuario.cpf}"
disabled>

</div>



<div class="mb-2">

<label>Nome</label>

<input
class="form-control"
id="edit-nome"
value="${usuario.nome}">

</div>



<div class="mb-2">

<label>Email</label>

<input
class="form-control"
id="edit-email"
value="${usuario.email}">

</div>



<div class="mb-2">

<label>Tipo usuário</label>


<select
class="form-control"
id="edit-tipoUsuario">

<option
${usuario.tipoUsuario==="Aluno" ? "selected" : ""}>

Aluno

</option>


<option
${usuario.tipoUsuario==="Professor" ? "selected" : ""}>

Professor

</option>


<option
${usuario.tipoUsuario==="Servidor" ? "selected" : ""}>

Servidor

</option>


</select>


</div>



<div class="mb-2">

<label>Telefone</label>

<input
class="form-control"
id="edit-telefone"
value="${usuario.telefone}">

</div>




<div class="mb-2">

<label>Registro</label>

<input
class="form-control"
id="edit-registro"
value="${usuario.registro}">

</div>



<div class="mb-2">

<label>Nova senha</label>

<input
type="password"
class="form-control"
id="edit-senha">

</div>



<div class="mb-3">

<label>Confirmar senha</label>

<input
type="password"
class="form-control"
id="edit-confirmar-senha">

</div>



<button
class="btn btn-success"
onclick="salvarEdicaoPerfil()">

Salvar

</button>


<button
class="btn btn-secondary"
onclick="cancelarEdicaoPerfil()">

Cancelar

</button>

`;


form.style.display =
"block";


});



// cancelar edição

function cancelarEdicaoPerfil(){


document.getElementById("formPerfil")
.style.display =
"none";


document.getElementById("dadosPerfil")
.style.display =
"block";


}

// ======================================================
// SALVAR EDIÇÃO
// ======================================================


async function salvarEdicaoPerfil(){


    const nome =
    document.getElementById("edit-nome").value;


    const email =
    document.getElementById("edit-email").value;


    const telefone =
    document.getElementById("edit-telefone").value;


    const registro =
    document.getElementById("edit-registro").value;


    const tipoUsuario =
    document.getElementById("edit-tipoUsuario").value;


    const senha =
    document.getElementById("edit-senha").value;


    const confirmarSenha =
    document.getElementById("edit-confirmar-senha").value;



    // valida campos obrigatórios

    if(!nome || !email){


        alert("Nome e email são obrigatórios!");


        return;


    }



    // valida senha

    if(senha && senha !== confirmarSenha){


        alert("As senhas não coincidem.");


        return;


    }



    // Dados enviados para API

    const corpo = {


        nome,

        email,

        telefone,

        registro,

        tipoUsuario


    };



    // Só envia senha se preencher

    if(senha){


        corpo.senha =
        senha;


    }



    try{


        const resposta =
        await fetch(

            `${API_BASE}/usuarios/${encodeURIComponent(usuario.cpf)}`,

            {

                method:"PUT",


                headers:{

                    "Content-Type":"application/json"

                },


                body:
                JSON.stringify(corpo)


            }

        );



        if(!resposta.ok){


            const dados =
            await resposta.json();



            alert(

                dados.erro ||

                "Erro ao atualizar perfil."

            );



            return;


        }



        // Atualiza sessão local

        usuario.nome =
        nome;


        usuario.email =
        email;


        usuario.telefone =
        telefone;


        usuario.registro =
        registro;


        usuario.tipoUsuario =
        tipoUsuario;



        localStorage.setItem(

            "usuarioLogado",

            JSON.stringify(usuario)

        );



        preencherPerfil();


        cancelarEdicaoPerfil();



        alert(

            "Perfil atualizado com sucesso!"

        );



    }catch(erro){


        alert(

            "Não foi possível conectar ao servidor."

        );


    }


}

// ======================================================
// ESTATÍSTICAS DO PERFIL
// ======================================================


async function carregarEstatisticas(){


    if(!usuario){

        return;

    }


    try{


        const [
            respPostagens,
            respNotificacoes
        ] = await Promise.all([


            fetch(
                `${API_BASE}/postagens?cpf=${encodeURIComponent(usuario.cpf)}`
            ),


            fetch(
                `${API_BASE}/notificacoes/${encodeURIComponent(usuario.cpf)}`
            )


        ]);



        const postagens =
        await respPostagens.json();


        const notificacoes =
        await respNotificacoes.json();



        // total de postagens

        document.getElementById("qtdPostagens").textContent =
        postagens.length;



        // objetos devolvidos

        const devolvidos =
        postagens.filter(post =>

            post.status_postagem === "Devolvido"

        );


        document.getElementById("qtdDevolvidos").textContent =
        devolvidos.length;



        // notificações

        document.getElementById("qtdNotificacoes").textContent =
        notificacoes.length;



    }catch(erro){


        console.log(
            "Erro ao carregar estatísticas:",
            erro
        );


    }


}



// chama automaticamente

carregarEstatisticas();

// ======================================================
// SAIR DO SISTEMA
// ======================================================


document
.getElementById("btnSair")
.addEventListener("click", async function(){


    try{


        // avisa o backend que saiu
        await fetch(
            `${API_BASE}/logout`,
            {

                method:"POST",

                headers:{
                    "Content-Type":"application/json"
                },

                body:
                JSON.stringify({

                    cpf:usuario.cpf

                })

            }
        );


    }catch(erro){


        console.log(
            "Erro no logout:",
            erro
        );


    }


    // limpa sessão do navegador

    localStorage.removeItem(
        "usuarioLogado"
    );


    // volta para o feed

    window.location.href =
    "/html/index.html";


});

// ======================================================
// EXCLUIR CONTA
// ======================================================


document
.getElementById("btnExcluirConta")
.addEventListener("click", async function(){


    const confirmar =
    confirm(
        "Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita."
    );


    if(!confirmar){

        return;

    }



    try{


        const resposta =
        await fetch(
            `${API_BASE}/usuarios/${encodeURIComponent(usuario.cpf)}`,
            {

                method:"DELETE"

            }
        );



        if(!resposta.ok){


            const dados =
            await resposta.json();


            alert(
                dados.erro ||
                "Não foi possível excluir a conta."
            );


            return;


        }



        // remove sessão

        localStorage.removeItem(
            "usuarioLogado"
        );



        alert(
            "Conta excluída com sucesso!"
        );



        // volta para login

        window.location.href =
        "/html/login.html";



    }catch(erro){


        alert(
            "Não foi possível conectar ao servidor."
        );


        console.log(erro);


    }


});