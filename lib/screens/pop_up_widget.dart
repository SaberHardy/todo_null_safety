import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_with_nullsafety/database/db_helper.dart';
import 'package:todo_with_nullsafety/models/note_model.dart';
import 'package:todo_with_nullsafety/screens/home_page.dart';


class PopUpWindow extends StatefulWidget {
  final Note? note;
  final Function? updateNoteList;
  PopUpWindow({Key? key, this.note, this.updateNoteList}) : super(key: key);

  @override
  State<PopUpWindow> createState() => _PopUpWindowState();
}

class _PopUpWindowState extends State<PopUpWindow> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _dateController = TextEditingController();

  final List<String> _priorities = ["Low", "Medium", "High"];

  String _priority = "Low";

  String _title = '';

  DateTime _date = DateTime.now();

  final DateFormat _dateFormat = DateFormat("MMM dd, yyyy");

  String titleText = "Add note";

  String btnText = "Add Note";

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _title = widget.note!.title!;
      _date = widget.note!.date!;
      _priority = widget.note!.priority!;

      setState(() {
        btnText = "Update Note";
        titleText = "Update Note";
      });
    } else {
      setState(() {
        btnText = "Add Note";
        titleText = "Add Note";
      });
    }
    _dateController.text = _dateFormat.format(_date);
  }

  _datePickerHandler() async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(1900),
        lastDate: DateTime(2500));

    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormat.format(date);
    }
  }

  _submit() {

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Note note = Note(title: _title, date: _date, priority: _priority);
      if (widget.note == null) {
        note.status = 0;
        DatabaseHelper.instance.insertNote(note);
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (_) => HomePage()),
                (Route<dynamic> route) => false);
      } else {
        note.id = widget.note!.id;
        note.status = widget.note!.status;
        DatabaseHelper.instance.updateNote(note);
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (_) => HomePage()),
                (Route<dynamic> route) => false);
      }
      widget.updateNoteList!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Popup example'),
      actions: <Widget>[
        Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: TextFormField(
                      // controller: null,
                      decoration: InputDecoration(
                        labelText: 'Add note',
                        labelStyle: const TextStyle(
                            color: Colors.indigoAccent, fontSize: 20),
                        hintText: 'tommorows\'s task',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.5),
                        ),
                      ),
                      validator: (value) => value!.trim().isEmpty
                          ? "Enter a text please" : null,
                      onSaved: (input) => _title = toBeginningOfSentenceCase(input!)!,
                      initialValue: _title,
                    )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: TextFormField(
                      readOnly: true,
                      controller: _dateController,
                      decoration: InputDecoration(
                          labelText: 'Date',
                          labelStyle: TextStyle(
                              color: Colors.indigoAccent, fontSize: 20),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(10.5))),
                      onTap: _datePickerHandler),
                ),

                /// DROPDOWN PICKER
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: DropdownButtonFormField(
                      dropdownColor: Colors.white70,
                      elevation: 9,
                      isDense: true,
                      icon: const Icon(Icons.arrow_circle_down,
                          color: Colors.deepPurple),
                      items: _priorities
                          .map((String priority) => DropdownMenuItem(
                          child: Text(priority,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20)),
                          value: priority))
                          .toList(),
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          labelText: "Priority",
                          labelStyle: const TextStyle(
                              color: Colors.indigoAccent, fontSize: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                      value: _priority,
                      validator: (value) => _priority == null
                          ? "Please select priority"
                          : null,
                      onChanged: (value) => setState(() {
                        _priority = value.toString();
                      }),
                    )),

                /// Submit Button
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(152.0),
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      titleText,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 30),
                    ),
                  ),
                ),

                ///Delete Button

                // widget.note != null
                //     ? Container(
                //   margin: const EdgeInsets.symmetric(vertical: 20.0),
                //   height: 60.0,
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     color: Theme.of(context).primaryColor,
                //     borderRadius: BorderRadius.circular(30.0),
                //   ),
                //   child: ElevatedButton(
                //     child: const Text(
                //       "Delete Note",
                //       style: TextStyle(
                //           color: Colors.white, fontSize: 20.0),
                //     ),
                //     onPressed: (){},
                //   ),
                // )
                //     : const SizedBox.shrink()
              ],
            ))
      ],
    );
  }
}
