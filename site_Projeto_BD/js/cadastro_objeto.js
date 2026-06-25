// =====================================================
// PRÉ-VISUALIZAÇÃO DA IMAGEM
// Responsável por exibir uma miniatura da foto
// selecionada pelo usuário antes do envio.
// =====================================================

// Captura o campo de upload de arquivo
const foto = document.querySelector('input[type="file"]');

// Captura o elemento de imagem que exibirá a prévia
const preview = document.getElementById('preview');

// Executa quando o usuário seleciona uma imagem
foto.addEventListener('change', function(){

    // Obtém o primeiro arquivo selecionado
    const arquivo = this.files[0];

    // Verifica se existe um arquivo selecionado
    if(arquivo){

        // Cria uma URL temporária para exibir a imagem
        preview.src = URL.createObjectURL(arquivo);

        // Torna a imagem visível na página
        preview.style.display = "block";
    }

});

// =====================================================
// LOCAIS DISPONÍVEIS POR CAMPUS
// Estrutura utilizada para preencher dinamicamente
// a lista de locais conforme o campus selecionado.
// =====================================================

const locais = {

    // Campus Darcy Ribeiro
    darcy: [
        "Biblioteca Central (BCE)",
        "Instituto Central de Ciências (ICC)",
        "Faculdade de Tecnologia (FT)",
        "Faculdade de Educação (FE)",
        "Faculdade de Direito (FD)",
        "FACE",
        "Instituto de Química (IQ)",
        "Instituto de Ciências Biológicas (IB)",
        "Centro Olímpico (CO)",
        "Centro de Vivência 1",
        "Centro de Vivência 2",
        "Reitoria",
        "Pavilhão Anísio Teixeira (PAT)",
        "Pavilhão João Calmon (PJC)",
        "BSA Sul",
        "BSA Norte",
        "CIC/EST",
        "Restaurante Universitário (RU)"
    ],

    // Campus Gama
    fga: [
        "CEDIS",
        "MESP",
        "UED",
        "UAC",
        "Restaurante Universitário (RU)"
    ],

    // Campus Ceilândia
    fce: [
        "UEP",
        "UED",
        "UAC",
        "Restaurante Universitário (RU)",
        "Estacionamento"
    ],

    // Campus Planaltina
    fup: [
        "Restaurante Universitário (RU)",
        "Estacionamento",
        "Núcleo de Estudos e Pesquisas Ambientais Limnológicas"
    ]
};

// =====================================================
// CAPTURA DOS ELEMENTOS DO FORMULÁRIO
// =====================================================

// Campo de seleção de campus
const campusSelect = document.getElementById("campus");

// Campo de seleção de localização
const localizacaoSelect = document.getElementById("localizacao");

// Campo de texto exibido quando o local não existir na lista
const campoOutro = document.getElementById("campoOutro");

// =====================================================
// ATUALIZAÇÃO DOS LOCAIS DE ACORDO COM O CAMPUS
// =====================================================

campusSelect.addEventListener("change", function(){

    // Obtém o campus selecionado
    const campusEscolhido = this.value;

    // Limpa os locais carregados anteriormente
    localizacaoSelect.innerHTML =
        '<option value="">Selecione o local</option>';

    // Oculta o campo "Outro Local"
    campoOutro.style.display = "none";

    // Verifica se existem locais cadastrados para o campus
    if(locais[campusEscolhido]){

        // Percorre todos os locais do campus selecionado
        locais[campusEscolhido].forEach(function(local){

            // Cria uma nova opção
            const option = document.createElement("option");

            // Define valor e texto da opção
            option.value = local;
            option.textContent = local;

            // Adiciona ao select de localização
            localizacaoSelect.appendChild(option);

        });

        // Cria opção para locais não cadastrados
        const outro = document.createElement("option");

        outro.value = "outro";
        outro.textContent = "Local não listado";

        // Adiciona a opção ao final da lista
        localizacaoSelect.appendChild(outro);

    }

});

// =====================================================
// EXIBIÇÃO DO CAMPO "OUTRO LOCAL"
// =====================================================

localizacaoSelect.addEventListener("change", function(){

    // Se o usuário selecionar "Local não listado"
    if(this.value === "outro"){

        // Exibe o campo de texto
        campoOutro.style.display = "block";

        // Torna o campo obrigatório
        document.querySelector(
            'input[name="outro_local"]'
        ).required = true;

    } else {

        // Oculta o campo
        campoOutro.style.display = "none";

        // Remove obrigatoriedade
        document.querySelector(
            'input[name="outro_local"]'
        ).required = false;

    }

});

// =====================================================
// CADASTRO DA POSTAGEM
// =====================================================

// Captura o formulário principal
const form = document.getElementById("cadastroObjetoForm");

// Executa quando o usuário clica em Publicar Objeto
form.addEventListener("submit", function(event){

    // Impede o envio padrão do formulário
    event.preventDefault();

    // Recupera o usuário atualmente logado
    const usuario =
    JSON.parse(
        localStorage.getItem("usuarioLogado")
    );

    // Verifica se existe usuário autenticado
    if(!usuario){

        alert("Faça login primeiro!");

        window.location.href = "/html/login.html";

        return;
    }

    // =====================================================
    // CRIAÇÃO DO OBJETO POSTAGEM
    // Estrutura semelhante à tabela Postagem do banco.
    // =====================================================

    const postagem = {

        // CPF do usuário que realizou a postagem
        cpf: usuario.cpf,

        // Nome do objeto
        nomeObjeto:
        document.querySelector(
            '[name="nome_objeto"]'
        ).value,

        // Cor do objeto
        cor:
        document.querySelector(
            '[name="cor"]'
        ).value,

        // Tamanho do objeto
        tamanho:
        document.querySelector(
            '[name="tamanho"]'
        ).value,

        // Descrição detalhada
        descricao:
        document.querySelector(
            '[name="descricao"]'
        ).value,

        // Categoria selecionada
        categoria:
        document.querySelector(
            '[name="categoria"]'
        ).value,

        // Tipo da postagem
        // Perdido ou Encontrado
        tipo_postagem:
        document.querySelector(
            '[name="tipo_postagem"]'
        ).value,

        // Campus selecionado
        campus:
        document.querySelector(
            '[name="campus"]'
        ).value,

        // Local informado
        localizacao:
        document.querySelector(
            '[name="localizacao"]'
        ).value,

        // Nome do usuário responsável pela postagem
        usuario:
        usuario.nome,

        // Status inicial da postagem
        status_postagem:
        "Aberto",

        // Data e hora de criação
        data_hora:
        new Date().toLocaleString("pt-BR"),

        // Foto selecionada pelo usuário
        foto:
        preview.src

    };

    // =====================================================
// RECUPERA POSTAGENS EXISTENTES
// =====================================================

const postagens =
JSON.parse(
    localStorage.getItem("postagens")
) || [];

// Adiciona a nova postagem
postagens.push(postagem);

// Salva novamente as postagens
localStorage.setItem(
    "postagens",
    JSON.stringify(postagens)
);

// =====================================================
// CADASTRA UMA NOVA NOTIFICAÇÃO
// =====================================================

// Recupera as notificações existentes
const notificacoes =
JSON.parse(
    localStorage.getItem("notificacoes")
) || [];

// Adiciona a nova notificação
notificacoes.unshift({

    mensagem:
        `Sua publicação "${postagem.nomeObjeto}" foi criada com sucesso.`,

    data:
        new Date().toLocaleString("pt-BR")

});

// Salva novamente as notificações
localStorage.setItem(
    "notificacoes",
    JSON.stringify(notificacoes)
);

// Informa sucesso ao usuário
alert("Objeto publicado com sucesso!");

// Redireciona para o feed principal
window.location.href = "/html/index.html";

});
