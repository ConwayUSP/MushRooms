# MushRooms

Um roguelike coop com exploração, combate e construção de cafofos. Se torne um poderoso cogumelo e descubra o sentido da vida com seus amigos :)

Este é um trabalho em progresso feito com amor ([love](https://love2d.org/wiki/love)). 

## Como rodar o projeto

Instale o Love2D versão 11.0+ no seu computador e execute o seguinte comando na pasta raiz do projeto:

``` sh
love .
```

## Como buildar as páginas web de documentação

Instale o NodeJS na sua máquina, vá para a pasta `/docs` e execute o comando abaixo:

``` sh
node mushdocs.js
```

O output do script fica em `/docs/out/`, lá você encontrará o `index.html` que deve ser aberto com algum navegador para a visualização da documentação gerada.

## Colaborando com o projeto

A partir daqui, irei assumir que você é um membro da Conway USP e que fez a trilha de Lua e Love2D.

Abaixo irei explicar algumas coisas sobre a code-base que serão úteis para você se familiarizar mais rápido com a estrutura do código. Aqui vai um índice:

1. Estrutura de arquivos
2. Entidades e OOP
3. Câmera e renderização
4. Salas
5. UI

### 1. Estrutura de arquivos

A estrutura de arquivos é relativamente simples. Na pasta raiz, temos poucos arquivos de código:

- `conf.lua`: não importa muito, é só uma configuraçãozinha básica do love
- `main.lua`: é onde fica o `init`, o `update` e o `draw` geral, além de todos os callbacks do Love2D
- `game.lua`: é onde colocamos algumas funções e estruturas mais gerais do jogo tentando não poluir muito o `main.lua`. Lá nós temos por exemplo a função que inicializa o mundo do jogo após o player apertar "start" no menu inicial.

Além disso, temos algumas pastas importantes.

- A `assets/` é onde colocamos todas as animações, sprites, fontes, áudios e diálogos do jogo (cada um com sua subpasta, como `assets/animations/`);
- A `docs/` é onde está o script que gera a documentação automática do jogo;
- A `libs/` é onde colocamos dependências de terceiros. O MushRooms é fruto de um esforço para construir um jogo do "zero absoluto", então as dependências são poucas e servem principalmente para dev-tools (como o AppleCake para profiling);
- A `shaders/` é onde se encontram todos os `.glsl` que usamos para embelezar nosso querido joguinho;
- Por último, temos a `modules/`, que é onde fica 99% do código fonte do jogo. Sua estrutura merece uma explicação separada.

Dentro de `modules/` nós temos as pastas `UI/`, `constructors/`, `engine/`, `entities/`, `systems/`, `tooling/` e `utils/`. Os nomes tentam ser auto-explicativos, mas vale um esforço para justificar alguns deles. Por exemplo, a `UI/` é uma pasta própria e não está em `engine/` por exemplo pois ela é um monstro de 7 cabeças que nós queremos transformar em um projeto _open source_ próprio no futuro. Já o `constructors/` é onde colocamos os repetecos de construtores de todas as entidades definidas em `entities/`. Então temos, por exemplo, a definição de `Enemy` em `enemy.lua` na pasta `entities/`, mas os construtores de inimigos em si (como o Nuclear Cat) estão em `enemies.lua`, na pasta `constructors/`.

Outra coisa que vale ser ressaltada é a leve ambiguidade entre `systems/` e `engine/`. A zona é realmente cinzenta, mas a forma que gosto de pensar é que se algo é geral o suficiente para ser facilmente usado para criar outros jogos então vai em `engine/`, mas se é algo mais específico da implementação do MushRooms vai em `systems/`.

No `tooling/` é onde a gente coloca boa parte das merdas para debug, e no `utils/` é onde colocamos as outras merdas que não são para debug. Três arquivos do `utils/` que merecem atenção especial são o `entities.lua`, o `constructors.lua` e o `types.lua`. Eles são importantes pois mexemos neles sempre que queremos adicionar algo novo no jogo. No `types.lua` colocamos os "enums" representando os tipos no jogo, então muitas entidades tem um atributo `.type` que vai ter um valor como `PLAYER` ou `ENEMY`, definidos em `types.lua`. No `entities.lua` nós registramos a existência de quase todas as entidades do jogo, usando uma estrutura própria chamada `EntityReg`, que guarda o nome, o tipo e possivelmente a descrição dessa entidade. Esses registros são globais, e também são anotados com LETRAS MAIÚSCULAS. Além disso, eles são usados para ajudar a indexar algumas tabelas, como por exemplo a tabela presente no último arquivo citado: o `constructors.lua`. Nele, a gente tem uma tabelona que linka todos os tipos de entidade com seus construtores (cada tipo de entidade tem um mapa cuja chave é o **nome** de uma entidade daquele tipo e o valor é uma **função** construtora daquela entidade).

O restante dos arquivos do projeto farão mais sentido em seus respectivos contextos.

## 2. Entidades e OOP

Inicialmente, evitamos usar muito OOP já que Lua não é exatamente a linguagem mais adequada para isso, mas por algum motivo acabamos nos rendendo um pouco. Ainda assim, a hierarquia usada é bem básica. No topo, temos a classe `Entity`, declarada em `modules/entities/entity.lua`. `Entity` possui informações bem básicas sobre a física e a identidade de um objeto. Praticamente todas as outras classes de objetos que podem ser vistos nas salas (com excessão das salas) herdam de `Entity`. Contudo, temos duas classes que não são filhas diretas de `Entity`, que são a classe `Player` e a `Enemy`. Essas duas são subclasses de `Mortal`, que por sua vez sim herda de `Entity`. Membros da classe `Mortal` possuem atributos relacionados a `hp` e sua perda (quem diria?).

Basicamente é isso, o código é bem mais procedural do que orientado a objetos de fato. A realidade dura é que temos uma mistura porca das duas abordagens, mas faz parte do rock.

## 3. Câmeras e renderização

As câmeras são parte crucial da engine. Como o jogo é multiplayer split-screen, temos uma câmera para cada jogador. Cada câmera possui um `canvas` próprio (sim, o canvas do próprio Love2D). Ou seja, primeiro nós desenhamos a visão de cada jogador no canvas das câmeras e então desenhamos os canvas na janela do jogo. Mexer com a câmera pode ser uma dor de cabeça sinistra, pois os atributos de `zoom`, `shake` e outros podem ferrar completamente a matemática vetorial que precisamos fazer em certas situações. Dito isso, a situação já foi pior, então fiquemos felizes. Outro detalhe importante sobre as câmeras é que, como o Love não permite que um canvas mude de tamanho, precisamos criar câmeras novas toda vez que a janela muda de tamanho ou um player novo entra no jogo.

## 4. Salas

As salas são as estruturas centrais do universo do jogo. Tudo está em uma sala e todos sabem a sala onde estão (blá blá blá referência circular, relaxa q nn dá nada). As salas são basicamente o "entrypoint" dos updates e draws. Isso é bom pois pensando no desempenho do código nós só nos importamos com atualizar e renderizar as entidades que estão relativamente perto do player (por exemplo, na mesma sala ou salas adjacentes), então fazer essa otimização fica trivial segregando tudo por sala. Outra coisa boa é que a geração procedural do mundo fica centralizada em uma tarefa simples de ser concebida: como criar uma sala aleatória?

Temos no código uma lista global de salas ativas (que são basicamente as salas onde há players), e a ideia é que as coisas só acontecem em salas ativas, o resto do mundo vira uma escuridão estática. Com isso, temos também algumas desvantagens, por exemplo, se um inimigo dá um tiro e o player sai da sala enquanto este tiro está no ar, quando ele voltar à sala o tiro estará na mesma posição, pois não foi atualizado.

Além de uma lista global de salas (`rooms`), também temos uma lista global de portas (`doors`) e uma lista de paredes (`walls`). Por motivos de força maior, as salas compartilham as paredes de cima e de baixo com outras salas, mas as paredes da esquerda e da direita são únicas de uma sala só. Ou seja, na prática temos duas portas entre salas horizontalmente conectadas.

## 5. UI

Como os sistemas de UI disponíveis na comunidade do Love2D são uma porcaria (perdão, mas é verdade), nós criamos o nosso próprio. Ele é uma porcaria? Sim, também! Mas pelo menos é uma porcaria que funciona para o nosso caso de uso. A estrutura é a seguinte:

- Temos a classe `UIManager`, que irá cuidar de um conjunto de cenas (da classe `UIScene`). Cada cena pode ser pensada como uma "tela" de UI; por exemplo, a interface do inventário é uma cena.
- Cada cena é composta e cuida de elementos de UI (da classe `UIElement`). Os elementos ficam dispostos em uma matriz 3D (calma). Uma das dimensões é representada como camadas, se você já mexeu em um software de desenho ou edição de imagem, está familiarizado com o conceito. As outras duas dimensões são simplesmente uma grade que indica a disposição lógica dos elementos na UI.
- A diferença entre a disposição lógica e física é importante. A posição lógica nos diz o que acontece quando você usa as setinhas para navegar pela UI. Se você está no elemento na posição (2, 3) da grade e clica na seta para a esquerda, você irá para o elemento na posição (1, 3) - ou o mais próximo dele, caso o slot esteja vazio. Já a posição física dos elementos simplesmente diz onde ele será renderizado na tela, e não precisa necessariamente ser compatível com a posição lógica, apesar de ser mais intuitivo ao usuário se tiver uma relação. No geral, a cena não se importa com a disposição física dos elementos.

Os `UIElements` são equivalentes aos "widgets" comuns em outras bibliotecas. Implementar um novo widget é criar uma nova classe que herda de `UIElement` e que tenha (se quiser) uma função de update e uma função `onClick`... o céu é o limite.

Um fato importante é que o `UIManager` possui seu próprio canvas, o qual será renderizado no canvas da câmera do jogador que está com aquela UI aberta (cada jogador possui seu `UIManager`). A UI global é renderizada diretamente na janela pelo UIManager global.
