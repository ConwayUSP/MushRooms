const fs = require('fs');
const path = require('path');

// Configuração
const SOURCE_DIR = '../modules/';
const OUT_DIR = './out';

function ensureDir(dir) {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function getLuaFiles(dir, fileList = []) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const filePath = path.join(dir, file);
        if (fs.statSync(filePath).isDirectory()) {
            getLuaFiles(filePath, fileList);
        } else if (filePath.endsWith('.lua')) {
            fileList.push(filePath);
        }
    }
    return fileList;
}

function parseFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf-8');
    const lines = content.split('\n');
    
    let relPath = path.relative(SOURCE_DIR, filePath).replace(/\\/g, '/');
    const htmlName = relPath.replace(/\//g, '_').replace('.lua', '.html');

    const docs = { name: path.basename(filePath), relPath: relPath, htmlName: htmlName, classes: [] };
    let currentClass = null;
    let commentBuffer = [];

    for (let line of lines) {
        const trimmedLine = line.trim();
        
        // Procura definição de classe @class
        const classMatch = trimmedLine.match(/^---\s*@class\s+([A-Za-z0-9_.]+)/);
        if (classMatch) {
            currentClass = { name: classMatch[1], attributes: [], methods: [] };
            docs.classes.push(currentClass);
            commentBuffer = []; // Limpa comentários soltos antes da classe
            continue;
        }

        // Checa atributos e métodos @field
        const fieldMatch = trimmedLine.match(/^---\s*@field\s+(?:public\s+|protected\s+|private\s+)?([A-Za-z0-9_.?]+)\s+(.*)/);
        if (fieldMatch && currentClass) {
            const fieldName = fieldMatch[1];
            const fieldType = fieldMatch[2];
            
            // Separa métodos (fun) de atributos normais (string, number, etc)
            if (fieldType.startsWith('fun(') || fieldType.startsWith('fun')) {
                currentClass.methods.push({ name: fieldName, signature: fieldType, description: '' });
            } else {
                currentClass.attributes.push({ name: fieldName, type: fieldType });
            }
            commentBuffer = [];
            continue;
        }

        // Se a linha começa com -- mas não foi pêga pelos if's acima, é comentário real
        if (trimmedLine.startsWith('--')) {
            commentBuffer.push(trimmedLine);
            continue;
        }

        const funcMatch = trimmedLine.match(/^function\s+([A-Za-z0-9_.]+)[:.]([A-Za-z0-9_]+)\s*\((.*)\)/);
        if (funcMatch) {
            const className = funcMatch[1];
            const methodName = funcMatch[2];
            const args = funcMatch[3];

            let targetClass = docs.classes.find(c => c.name === className);
            
            if (!targetClass) {
                targetClass = { name: className, attributes: [], methods: [] };
                docs.classes.push(targetClass);
            }

            const cleanedDescription = commentBuffer
                .filter(c => !c.match(/^--+\s*@param/))
                .filter(c => !c.match(/^--+\s*@return/))
                .map(c => c.replace(/^---+@?/, '').replace(/^--\s*/, '').trim())
                .filter(c => c !== '') 
                .join('<br>');

            let existingMethod = targetClass.methods.find(m => m.name === methodName);
            
            if (existingMethod) {
                // Atualiza o método existente
                existingMethod.description = cleanedDescription;
            } else {
                // Adiciona o método caso ele não tenha sido mapeado por um @field
                targetClass.methods.push({ 
                    name: methodName, 
                    signature: `fun(${args})`, 
                    description: cleanedDescription 
                });
            }

            commentBuffer = [];
            continue;
        }

        if (trimmedLine === '') continue;
        commentBuffer = [];
    }

    return docs;
}

function generateHTML(docData) {
    let html = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>${docData.name} - Documentação</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <nav><a href="index.html"><- voltar para o índice</a></nav>
        <h1>Arquivo: <code>${docData.name}</code></h1>
    `;

    docData.classes.forEach(c => {
        html += `<div class="class-block">`;
        html += `<h2>Classe: <code>${c.name}</code></h2>`;
        
        if (c.attributes.length > 0) {
            html += `<h3>Atributos</h3><ul>`;
            c.attributes.forEach(attr => {
                html += `<li><strong>${attr.name}</strong> : <span class="type">${attr.type}</span></li>`;
            });
            html += `</ul>`;
        }

        if (c.methods.length > 0) {
            html += `<h3>Métodos</h3>`;
            c.methods.forEach(method => {
                html += `
                <div class="method">
                    <h4>${method.name}</h4>
                    <p class="signature">${method.signature}</p>`;
                
                if (method.description) {
                    html += `<div class="description">${method.description}</div>`;
                }

                html += `</div>`;
            });
        }
        
        html += `</div><hr>`;
    });

    html += `</body></html>`;
    return html;
}

// Constrói o HTML da Árvore Recursivamente
function renderTreeHTML(node) {
    let html = '<ul class="file-tree">';
    
    // Ordena para que pastas apareçam antes dos arquivos
    const keys = Object.keys(node).sort((a, b) => {
        const isFolderA = !node[a].htmlName;
        const isFolderB = !node[b].htmlName;
        if (isFolderA && !isFolderB) return -1;
        if (!isFolderA && isFolderB) return 1;
        return a.localeCompare(b);
    });

    for (const key of keys) {
        const item = node[key];
        if (item.htmlName) {
            // É um arquivo (folha)
            html += `<li class="file"><a href="${item.htmlName}">${item.name}</a></li>`;
        } else {
            // É uma pasta (nó)
            html += `<li class="folder"><span class="folder-name">${key}</span>${renderTreeHTML(item)}</li>`;
        }
    }
    
    html += '</ul>';
    return html;
}

function buildDocs() {
    ensureDir(OUT_DIR);
    const luaFiles = getLuaFiles(SOURCE_DIR);
    const allDocs = [];
    const fileTree = {};

    luaFiles.forEach(file => {
        const docData = parseFile(file);
        if (docData.classes.length > 0) {
            allDocs.push(docData);
            fs.writeFileSync(path.join(OUT_DIR, docData.htmlName), generateHTML(docData));

            // Constrói a árvore de diretórios
            const pathParts = docData.relPath.split('/');
            let currentLevel = fileTree;
            
            for (let i = 0; i < pathParts.length - 1; i++) {
                const folder = pathParts[i];
                if (!currentLevel[folder]) {
                    currentLevel[folder] = {};
                }
                currentLevel = currentLevel[folder];
            }
            // Adiciona o arquivo no último nível
            const fileName = pathParts[pathParts.length - 1];
            currentLevel[fileName] = docData;
        }
    });

    let indexHtml = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Documentação da Engine</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <h1>Índice do Projeto</h1>
        <div class="tree-container">
            ${renderTreeHTML(fileTree)}
        </div>
    </body>
    </html>
    `;
    
    fs.writeFileSync(path.join(OUT_DIR, 'index.html'), indexHtml);

    const css = `
        body { font-family: ui-monospace, Geneva, Verdana; line-height: 1.6; max-width: 900px; margin: 0 auto; padding: 20px; color: #e0e0e0; background-color: #1e1e1e; }
        nav { margin-bottom: 20px; font-weight: bold; }
        a { color: #49ded4; text-decoration: none;}
        a:hover { text-decoration: underline; }
        h1 { color: #fffecc; border-bottom: 2px solid #333; padding-bottom: 10px; }
        h2 { color: #ffbd96; font-weight: 400;}
        h3 { color: #ff5471; margin-bottom: 5px; font-weight: 400; }
        ul { background: #252526; padding: 15px 15px 15px 35px; border-radius: 5px; }
        li { margin-bottom: 5px; }
        code { font-weight: none; font-size: 115%;}
        
        /* Estilos da Árvore de Arquivos */
        .tree-container { background: #252526; padding: 20px; border-radius: 5px; }
        ul.file-tree { background: transparent; padding: 0 0 0 20px; border-radius: 0; list-style-type: none; }
        .tree-container > ul.file-tree { padding-left: 0; }
        li.folder { margin-top: 8px; }
        .folder-name { color: #d9fbff; font-weight: 600; display: block; margin-bottom: 4px; }
        .folder-name::before { content: '🖿 '; }
        li.file::before { content: '◦ '; color: #B9fffa;}
        
        .class-block ul { width: 67%; }
        .type { color: #4ec9b0; font-family: monospace; font-size: 1rem; border-radius: 2px; background-color: #1e1e1e; padding: 3px;}
        .method { background: #28282a; width: 69%; padding: 10px 15px; margin-bottom: 15px; border-left: 4px solid #eee; }
        .method h4 { margin: 0 0 5px 0; color: #eee; font-size: 1.1em; }
        .signature { font-family: monospace; color: #4ec9b0; font-size: 1rem; margin: 0 0 10px 0; border-radius: 2px}
        .description { background: #1e1e1e; padding: 10px; font-size: 1.1em; color: #e0e0e0; border-radius: 0 3px 3px 0; font-family: monospace; }
        hr { border: 0; border-top: 1px solid #333; margin: 30px 0; }
    `;
    fs.writeFileSync(path.join(OUT_DIR, 'style.css'), css);

    console.log(`Documentação gerada! Árvore de arquivos criada em ${OUT_DIR}/`);
}

buildDocs();
