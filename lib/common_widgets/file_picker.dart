import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerWidget extends StatefulWidget {
  final String label;
  final void Function(PlatformFile? file) onChanged;

  const FilePickerWidget({
    super.key,
    required this.label,
    required this.onChanged,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  PlatformFile? _pickedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
      widget.onChanged(_pickedFile);
    }
  }

  void _clearFile() {
    setState(() => _pickedFile = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 6),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text("Choose File"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _pickedFile != null ? _pickedFile!.name : "No file chosen",
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: _pickedFile != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (_pickedFile != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearFile,
                  splashRadius: 18,
                  tooltip: "Clear",
                ),
            ],
          ),
        ],
      ),
    );
  }
}
