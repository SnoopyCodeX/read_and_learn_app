import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBar extends StatefulWidget {
  final ValueChanged<String> onQueryChanged;
  final void Function(String query) onSearch;
  final String hint;

  const SearchBar({
    Key? key,
    required this.onQueryChanged,
    required this.hint,
    required this.onSearch,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController? _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _searchController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: Colors.black87,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.only(
        left: 20,
        right: 10,
        top: 1,
        bottom: 1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: widget.hint,
                hintStyle: GoogleFonts.poppins(),
              ),
              cursorColor: Colors.black87,
              style: GoogleFonts.poppins(),
              textInputAction: TextInputAction.search,
              onSubmitted: (query) => widget.onSearch(query),
              onChanged: (query) => widget.onQueryChanged(query),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search_outlined),
            onPressed: () => widget.onSearch(_searchController!.text),
          ),
        ],
      ),
    );
  }
}
