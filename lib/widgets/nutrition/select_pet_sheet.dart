import 'package:flutter/material.dart';

class SelectPetSheet extends StatelessWidget {
  final List<Map<String, dynamic>> pets;
  final void Function(String petId) onSelect;

  const SelectPetSheet({
    super.key,
    required this.pets,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Select Pet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (pets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No pets found. Add a pet first.'),
            )
          else
            ...pets.map((p) {
              final petId = (p['_id'] ?? p['id']).toString();
              final name = (p['name'] ?? 'Pet').toString();
              final breed = (p['breed'] ?? '').toString();

              return ListTile(
                leading: const Icon(Icons.pets),
                title: Text(name),
                subtitle: Text(breed),
                onTap: () => onSelect(petId),
              );
            }),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
