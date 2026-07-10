// =====================================================
// CADASTRO / EDIÇÃO DE USUÁRIO
// =====================================================


// Verifica se abriu a tela em modo edição
const modoEdicao =
new URLSearchParams(window.location.search)
.get("editar");


// Recupera usuário logado
const usuarioEditando =
JSON.parse(
    localStorage.getItem("usuarioLogado")
);


// =====================================================
// PREENCHE CAMPOS QUANDO FOR EDIÇÃO
// =====================================================

if(modoEdicao && usuarioEditando){


    document.querySelector('[name="nome"]').value =
    usuarioEditando.nome;


    document.querySelector('[name="email"]').value =
    usuarioEditando.email;


    document.querySelector('[name="cpf"]').value =
    usuarioEditando.cpf;


    document.querySelector('[name="telefone"]').value =
    usuarioEditando.telefone;


    document.querySelector('[name="registro"]').value =
    usuarioEditando.registro;


    // CPF e email normalmente não são editados
    document.querySelector('[name="cpf"]').disabled = true;

    document.querySelector('[name="email"]').disabled = true;


}


// =====================================================
// FORMULÁRIO
// =====================================================

const form =
document.getElementById("cadastroForm");



form.addEventListener(
"submit",

async function(event){


event.preventDefault();


// =====================================================
// CAPTURA DOS CAMPOS
// =====================================================


const nome =
document.querySelector('[name="nome"]').value;


const email =
modoEdicao
? usuarioEditando.email
: document.querySelector('[name="email"]').value;


const cpf =
modoEdicao
? usuarioEditando.cpf
: document.querySelector('[name="cpf"]').value;


const telefone =
document.querySelector('[name="telefone"]').value;


const tipoUsuario =
document.querySelector('[name="tipo_usuario"]').value;


const registro =
document.querySelector('[name="registro"]').value;


const senha =
document.querySelector('[name="senha"]').value;


const confirmarSenha =
document.querySelector('[name="confirmar_senha"]').value;



// =====================================================
// VALIDAÇÃO DE SENHA
// =====================================================


// No cadastro a senha é obrigatória.
// Na edição pode ficar vazia.

if(!modoEdicao || senha){


    if(senha !== confirmarSenha){


        alert("As senhas não coincidem!");


        return;

    }

}



// =====================================================
// OBJETO USUÁRIO
// =====================================================


const usuario = {


    cpf,

    nome,

    email,

    registro,

    telefone,

    tipoUsuario,

    senha


};



// =====================================================
// DEFINE SE É POST OU PUT
// =====================================================


let url =
`${API_BASE}/usuarios`;


let metodo =
"POST";



if(modoEdicao){


    url =
    `${API_BASE}/usuarios/${cpf}`;


    metodo =
    "PUT";


}



// =====================================================
// ENVIA PARA API
// =====================================================


try{


    const resposta =
    await fetch(
        url,
        {

            method: metodo,


            headers:{

                "Content-Type":"application/json"

            },


            body:
            JSON.stringify(usuario)

        }
    );



    const dados =
    await resposta.json();



    if(!resposta.ok){


        alert(
            dados.erro ||
            "Não foi possível salvar."
        );


        return;


    }



    // =================================================
    // SE FOR EDIÇÃO ATUALIZA LOCALSTORAGE
    // =================================================


    if(modoEdicao){


        usuarioEditando.nome =
        nome;


        usuarioEditando.telefone =
        telefone;


        usuarioEditando.registro =
        registro;


        localStorage.setItem(
            "usuarioLogado",
            JSON.stringify(usuarioEditando)
        );


        alert("Perfil atualizado com sucesso!");


        window.location.href =
        "/html/perfil.html";


    }else{


        alert("Conta criada com sucesso!");


        window.location.href =
        "/html/login.html";


    }



}catch(erro){


    alert(
        "Não foi possível conectar ao servidor."
    );


}


});