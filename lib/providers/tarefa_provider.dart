import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/tarefa.dart';

enum FiltroTarefa {
  todas,
  pendentes,
  concluidas,
}

class TarefaProvider extends ChangeNotifier {
  List<Tarefa> _tarefas = [];

  bool _isLoading = false;

  FiltroTarefa _filtro = FiltroTarefa.todas;

  List<Tarefa> get tarefas =>
      List.unmodifiable(_tarefas);

  bool get isLoading => _isLoading;

  FiltroTarefa get filtro => _filtro;

  // EXERCÍCIO 01
  int get totalTarefas => _tarefas.length;

  int get totalConcluidas {
    return _tarefas
        .where((tarefa) => tarefa.concluida)
        .length;
  }

  int get totalPendentes {
    return _tarefas
        .where((tarefa) => !tarefa.concluida)
        .length;
  }

  // EXERCÍCIO 02
  List<Tarefa> get tarefasFiltradas {
    switch (_filtro) {
      case FiltroTarefa.pendentes:
        return _tarefas
            .where((tarefa) => !tarefa.concluida)
            .toList();

      case FiltroTarefa.concluidas:
        return _tarefas
            .where((tarefa) => tarefa.concluida)
            .toList();

      case FiltroTarefa.todas:
        return List.unmodifiable(_tarefas);
    }
  }

  void alterarFiltro(FiltroTarefa filtro) {
    _filtro = filtro;
    notifyListeners();
  }

  Future<void> carregarTarefas() async {
    _isLoading = true;
    notifyListeners();

    _tarefas =
        await DatabaseHelper.instance.queryAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> adicionarTarefa(
    String titulo,
  ) async {
    if (titulo.trim().isEmpty) {
      return;
    }

    final novaTarefa = Tarefa(
      titulo: titulo.trim(),
    );

    final id =
        await DatabaseHelper.instance.insert(
      novaTarefa,
    );

    _tarefas.insert(
      0,
      novaTarefa.copyWith(id: id),
    );

    notifyListeners();
  }

  Future<void> alternarStatus(
    Tarefa tarefa,
  ) async {
    final tarefaAtualizada = tarefa.copyWith(
      concluida: !tarefa.concluida,
    );

    await DatabaseHelper.instance.update(
      tarefaAtualizada,
    );

    final index = _tarefas.indexWhere(
      (t) => t.id == tarefa.id,
    );

    if (index != -1) {
      _tarefas[index] = tarefaAtualizada;
      notifyListeners();
    }
  }

  // EXERCÍCIO 03
  Future<void> editarTarefa(
    Tarefa tarefa,
    String novoTitulo,
  ) async {
    if (novoTitulo.trim().isEmpty) {
      return;
    }

    final tarefaAtualizada = tarefa.copyWith(
      titulo: novoTitulo.trim(),
    );

    await DatabaseHelper.instance.update(
      tarefaAtualizada,
    );

    final index = _tarefas.indexWhere(
      (t) => t.id == tarefa.id,
    );

    if (index != -1) {
      _tarefas[index] = tarefaAtualizada;
      notifyListeners();
    }
  }

  Future<void> removerTarefa(int id) async {
    await DatabaseHelper.instance.delete(id);

    _tarefas.removeWhere(
      (tarefa) => tarefa.id == id,
    );

    notifyListeners();
  }
}