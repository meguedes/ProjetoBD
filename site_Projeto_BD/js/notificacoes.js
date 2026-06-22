// ======================================================
// SISTEMA UNB - ACHADOS E PERDIDOS
// Página de Notificações
// ======================================================

// ------------------------------------------------------
// 1. MASSA DE DADOS
// ------------------------------------------------------
// Vetor que armazena as notificações do usuário.
// Cada objeto representa uma notificação exibida
// na central de notificações.

const notificacoes = [

{
    mensagem:
    "Você recebeu uma mensagem sobre Notebook Dell.",

    data:
    "Há 10 minutos"
},

{
    mensagem:
    "Seu objeto foi marcado como encontrado.",

    data:
    "Há 2 horas"
},

{
    mensagem:
    "Sua conta foi autenticada.",

    data:
    "Ontem"
}

];

// ------------------------------------------------------
// 2. REFERÊNCIA AO ELEMENTO HTML
// ------------------------------------------------------
// Obtém o container onde as notificações serão
// exibidas dinamicamente.

const container =
document.getElementById("listaNotificacoes");

// ------------------------------------------------------
// 3. EXIBIÇÃO DAS NOTIFICAÇÕES
// ------------------------------------------------------
// Percorre o vetor de notificações e cria um card
// para cada item encontrado.

notificacoes.forEach(notificacao => {

    // Adiciona uma nova notificação ao conteúdo
    // já existente dentro do container.

    container.innerHTML += `
    
    <div class="notificacao-card">

        <!-- Mensagem principal da notificação -->
        <p>

            ${notificacao.mensagem}

        </p>

        <!-- Data ou tempo relativo da notificação -->
        <span class="data">

            ${notificacao.data}

        </span>

    </div>

    `;

});

// ------------------------------------------------------
// FUNCIONAMENTO DO SISTEMA
// ------------------------------------------------------
// 1. As notificações são armazenadas no vetor
//    "notificacoes".
//
// 2. O elemento HTML "listaNotificacoes" é utilizado
//    para exibir as informações na tela.
//
// 3. O método forEach() percorre cada notificação.
//
// 4. Para cada item é criado um card contendo:
//      - Mensagem da notificação;
//      - Data ou horário da ocorrência.
//
// 5. Os cards são inseridos dinamicamente na página
//    utilizando a propriedade innerHTML.
//
// Exemplos de notificações:
// - Nova mensagem recebida;
// - Objeto encontrado;
// - Alteração de status;
// - Confirmação de cadastro;
// - Atualizações da conta.
//
// Dessa forma, o usuário pode acompanhar todas as
// atividades relacionadas aos seus objetos e à sua
// conta dentro do sistema.
// ------------------------------------------------------