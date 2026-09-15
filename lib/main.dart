import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/tarefa.dart';
import 'providers/tarefa_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          TarefaProvider()..carregarTarefas(),
      child: const TarefasApp(),
    ),
  );
}

class TarefasApp extends StatelessWidget {
  const TarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarefas com Provider & SQLite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _exibirDialogNovaTarefa(
    BuildContext context,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nova Tarefa'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Descrição da tarefa',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text
                    .trim()
                    .isNotEmpty) {
                  Provider.of<TarefaProvider>(
                    context,
                    listen: false,
                  ).adicionarTarefa(
                    controller.text,
                  );

                  Navigator.pop(ctx);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  // EXERCÍCIO 03
  void _exibirDialogEditarTarefa(
    BuildContext context,
    Tarefa tarefa,
  ) {
    final controller = TextEditingController(
      text: tarefa.titulo,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar Tarefa'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Descrição da tarefa',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text
                    .trim()
                    .isNotEmpty) {
                  Provider.of<TarefaProvider>(
                    context,
                    listen: false,
                  ).editarTarefa(
                    tarefa,
                    controller.text,
                  );

                  Navigator.pop(ctx);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Tarefas',
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Consumer<TarefaProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.isLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // EXERCÍCIO 01
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),
                color:
                    Colors.indigo.shade50,
                child: Text(
                  '${provider.totalConcluidas} de '
                  '${provider.totalTarefas} concluídas',
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // EXERCÍCIO 02
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilterChip(
                        label:
                            const Text('Todas'),
                        selected:
                            provider.filtro ==
                                FiltroTarefa
                                    .todas,
                        onSelected: (_) {
                          provider.alterarFiltro(
                            FiltroTarefa.todas,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChip(
                        label: const Text(
                          'Pendentes',
                        ),
                        selected:
                            provider.filtro ==
                                FiltroTarefa
                                    .pendentes,
                        onSelected: (_) {
                          provider.alterarFiltro(
                            FiltroTarefa
                                .pendentes,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChip(
                        label: const Text(
                          'Concluídas',
                        ),
                        selected:
                            provider.filtro ==
                                FiltroTarefa
                                    .concluidas,
                        onSelected: (_) {
                          provider.alterarFiltro(
                            FiltroTarefa
                                .concluidas,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: provider
                        .tarefasFiltradas
                        .isEmpty
                    ? Center(
                        child: Text(
                          provider
                                  .totalTarefas ==
                              0
                              ? 'Nenhuma tarefa cadastrada ainda!'
                              : 'Nenhuma tarefa neste filtro.',
                          style:
                              const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider
                            .tarefasFiltradas
                            .length,
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final tarefa =
                              provider
                                      .tarefasFiltradas[
                                  index];

                          return Card(
                            margin:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            // EXERCÍCIO 03
                            child: InkWell(
                              onLongPress: () {
                                _exibirDialogEditarTarefa(
                                  context,
                                  tarefa,
                                );
                              },
                              child: ListTile(
                                leading:
                                    Checkbox(
                                  value: tarefa
                                      .concluida,
                                  onChanged: (_) {
                                    provider
                                        .alternarStatus(
                                      tarefa,
                                    );
                                  },
                                ),
                                title: Text(
                                  tarefa.titulo,
                                  style:
                                      TextStyle(
                                    decoration: tarefa
                                            .concluida
                                        ? TextDecoration
                                            .lineThrough
                                        : TextDecoration
                                            .none,
                                    color: tarefa
                                            .concluida
                                        ? Colors.grey
                                        : Colors
                                            .black,
                                  ),
                                ),
                                subtitle:
                                    const Text(
                                  'Segure para editar',
                                ),
                                trailing:
                                    IconButton(
                                  icon:
                                      const Icon(
                                    Icons.delete,
                                    color:
                                        Colors.red,
                                  ),
                                  onPressed: () {
                                    provider
                                        .removerTarefa(
                                      tarefa.id!,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          _exibirDialogNovaTarefa(
            context,
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}