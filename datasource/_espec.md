
# Definição de Esquema de Banco de Dados em JSON

## Sobre o Modelo

Este modelo oferece uma maneira estruturada e sistemática de definir o esquema de um banco de dados relacional MySQL usando JSON. Ele facilita a automação da criação de tabelas, relacionamentos e gerenciamento de dados, sendo particularmente útil para projetos que exigem mapeamento de dados JSON para estruturas relacionais.

## Como Aplicar

Para aplicar este modelo, você define tabelas, campos e relacionamentos em um arquivo JSON. Cada tabela e seus campos são detalhados, incluindo tipos de dados e definições SQL. O modelo suporta a criação de relacionamentos 1:N e N:N através de tabelas de junção.

## Estrutura do Modelo

### Tabelas

```json
{
  "table_name": "nome_da_tabela",
  "lookup_field": "campo_pesquisa_principal",
  "fields": [
    {
      "field_name": "nome_campo",
      "data_type": "tipo_dado",
      "definitions": {
        "table_reference": "nome_tabela_referencia",
        "primary_key": true | false,
        "foreign_key": true | false,
        "reference": {"table": "tabela_referencia", "field": "campo_referencia"},
        "sql_definition": "definição_sql_do_campo"
      }
    }
  ]
}
```

### Dicionário de Tipos de Dados

#### Tipos de Dados JSON

- **`string`**: _Representa texto._
- **`int`**: _Números inteiros._
- **`decimal`**: _Números decimais._
- **`date`**: _Data no formato 'YYYY-MM-DD'._
- **`datetime`**: _Data e hora no formato 'YYYY-MM-DD HH:MM:SS'._
- **`boolean`**: _Verdadeiro (true) ou falso (false)._
- **`simple_list`**: _Lista de valores relacionados a outra tabela(1:N ou N:N)._
- **`json_array`**: _Array de objetos JSON._

#### Definições SQL Correspondentes

- **`VARCHAR(255)`**: _String com comprimento máximo de 255 caracteres._
- **`INT UNSIGNED`**: _Número inteiro positivo._
- **`DECIMAL(10,2)`**: _Número decimal com 10 dígitos e 2 decimais._
- **`DATE`**: _Data no formato 'YYYY-MM-DD'._
- **`DATETIME`**: _Data e hora no formato 'YYYY-MM-DD HH:MM:SS'._
- **`BOOLEAN`**: _Valor booleano (0 ou 1)._

## Relacionamentos

### 1:N (Um para Muitos)

Utilize o campo `foreign_key` em uma tabela para referenciar a chave primária de outra.

#### Exemplo de Relacionamento 1:N

```json
{
  "table_name": "pedidos",
  "lookup_field": "id",
  "fields": [
    {
      "field_name": "cliente_id",
      "data_type": "int",
      "definitions": {
        "foreign_key": true,
        "reference": {"table": "clientes", "field": "id"},
        "sql_definition": "INT UNSIGNED"
      }
    }
  ]
}
```

### N:N (Muitos para Muitos)

Crie uma tabela de junção com dois campos de chave estrangeira, cada um apontando para uma tabela diferente.

#### Exemplo de Relacionamento N:N

```json
{
  "table_name": "produto_pedido",
  "lookup_field": "id",
  "fields": [
    {
      "field_name": "produto_id",
      "data_type": "int",
      "definitions": {
        "foreign_key": true,
        "reference": {"table": "produtos", "field": "id"},
        "sql_definition": "INT UNSIGNED"
      }
    },
    {
      "field_name": "pedido_id",
      "data_type": "int",
      "definitions": {
        "foreign_key": true,
        "reference": {"table": "pedidos", "field": "id"},
        "sql_definition": "INT UNSIGNED"
      }
    }
  ]
}
```
