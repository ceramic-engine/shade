package shade.compiler;

/**
 * Generic string builder with indentation support.
 * Shared utility for all backends.
 */
class Printer {

    var _level:Int;
    var _buf:StringBuf;
    var _beginLine:Bool;
    var _endsBlock:Bool;
    final _indent:String;
    final _newline:String;

    public function new(indent:String = '    ', newline:String = '\n') {
        _indent = indent;
        _newline = newline;
        _beginLine = false;
        _endsBlock = false;
        clear();
    }

    public inline function indent() {
        _level++;
    }

    public inline function unindent() {
        _level--;
    }

    public inline function currentIndent():Int {
        return _level;
    }

    public inline function setIndent(level:Int) {
        _level = level;
    }

    public inline function endsBlock():Bool {
        return _endsBlock;
    }

    public inline function endBlock(str:String) {
        write(str);
        _endsBlock = true;
    }

    public function write(s:String) {
        if (_beginLine) {
            tab();
            _beginLine = false;
        }
        for (i in 0...s.length) {
            if (s.charCodeAt(i) != ' '.code || s.charCodeAt(i) != '\t'.code || s.charCodeAt(i) != '\n'.code || s.charCodeAt(i) != '\r'.code) {
                _endsBlock = false;
            }
        }
        _buf.add(s);
        return this;
    }

    public extern inline overload function writeln() {
        return newline();
    }

    public extern inline overload function writeln(s:String) {
        write(s);
        return newline();
    }

    function _writeln(s:String = "") {
        write(s);
        return newline();
    }

    public function newline() {
        _buf.add(_newline);
        _beginLine = true;
        return this;
    }

    public function tab() {
        for (_ in 0..._level)
            _buf.add(_indent);
        return this;
    }

    public extern inline overload function line() {
        return newline();
    }

    public extern inline overload function line(s:String) {
        return _line(s);
    }

    function _line(s:String) {
        tab();
        _buf.add(s);
        return newline();
    }

    public inline function clear() {
        _level = 0;
        _buf = new StringBuf();
    }

    public function toString() {
        return _buf.toString();
    }

}
