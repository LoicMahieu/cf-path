/**
 * @output false
 */
component {

  // Based on https://github.com/joyent/node/blob/b9bec2031e5f44f47cf01c3ec466ab8cddfa94f6/lib/path.js

  public string function basename(required string path, string ext = '') {
    var f = splitPath(path)[3];

    // TODO: make this comparison case-insensitive on windows?
    if (len(ext) && right(f, len(ext)) == ext) {
      f = mid(f, 1, len(f) - len(ext));
    }

    return f;
  }

  public string function extname(required string path) {
    return splitPath(path)[4];
  }

  public string function dirname(required string path) {
    var result = splitPath(path);
    var root = result[1];
    var dir = result[2];

    if (!len(root) && !len(dir)) {
      // No dirname whatsoever
      return '.';
    }

    if (len(dir)) {
      // It has a dirname, strip trailing slash
      dir = mid(dir, 1, len(dir) - 1);
    }

    return root & dir;
  }

  public string function join() {
    var path = '';
    for (var i = 1; i <= arrayLen(arguments); i++) {
      var segment = arguments[i];
      if (!isSimpleValue(segment)) {
        throw(type = 'TypeError', message = 'Arguments to path.join must be strings');
      }
      if (len(segment)) {
        if (!len(path)) {
          path &= segment;
        } else {
          path &= '/' & segment;
        }
      }
    }
    return normalize(path);
  }

  // path.normalize(path)
  // posix version
  public string function normalize(required string path) {
    var isAbsolute = isAbsolute(path);
    var trailingSlash = right(path, 1) == '/';
    var segments = listToArray(path, '/');
    var nonEmptySegments = [];

    // Normalize the path
    for (var i = 1; i <= arrayLen(segments); i++) {
      if (len(segments[i])) {
        nonEmptySegments.add(segments[i]);
      }
    }

    path = arrayToList(normalizeArray(nonEmptySegments, !isAbsolute), '/');

    if (!len(path) && !isAbsolute) {
      path = '.';
    }
    if (len(path) && trailingSlash) {
      path &= '/';
    }

    return (isAbsolute ? '/' : '') & path;
  }

  // posix version
  public string function isAbsolute(required string path) {
    return left(path, 1) == '/';
  }

  // path.resolve([from ...], to)
  public string function resolve() {
    var resolvedPath = '';
    var resolvedAbsolute = false;

    for (var i = arrayLen(arguments); i >= 0 && !resolvedAbsolute; i--) {
      var path = (i >= 1) ? arguments[i] : '';

      // Skip empty and invalid entries
      if (!isSimpleValue(path)) {
        throw(type = 'TypeError', message = 'Arguments to path.resolve must be strings');
      } else if (!len(path)) {
        continue;
      }

      resolvedPath = path & '/' & resolvedPath;
      resolvedAbsolute = left(path, 1) == '/';
    }

    // At this point the path should be resolved to a full absolute path, but
    // handle relative paths to be safe (might happen when process.cwd() fails)

    // Normalize the path
    resolvedPath = arrayToList(normalizeArray(listToArray(resolvedPath, '/'), !resolvedAbsolute), '/');

    var resolved = (resolvedAbsolute ? '/' : '') & resolvedPath;

    if (len(resolved)) {
      return resolved;
    }

    return '.';
  }

  public string function relative(required string from, required string to) {
    from = resolve(from);
    to = resolve(to);

    var fromParts = trimArray(listToArray(from, '/'));
    var toParts = trimArray(listToArray(to, '/'));

    var length = min(arrayLen(fromParts), arrayLen(toParts));
    var samePartsLength = length;
    for (var i = 1; i <= length; i++) {
      if (fromParts[i] != toParts[i]) {
        samePartsLength = i - 1;
        break;
      }
    }

    var outputParts = [];
    for (var i = samePartsLength; i < arrayLen(fromParts); i++) {
      outputParts.add('..');
    }

    outputParts.addAll(_arraySlice(toParts, samePartsLength + 1));

    return arrayToList(outputParts, '/');
  }












  // Split a filename into [root, dir, basename, ext], unix version
  // 'root' is just a slash, or nothing.
  variables.splitPathRe = createObject('java', 'java.util.regex.Pattern').compile('^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$');
  
  private array function splitPath(required string filename) {
    var matcher = splitPathRe.matcher(filename);

    if (!matcher.matches()) {
      return [];
    }

    var res = [];

    for (var i=1; i <= matcher.groupCount(); i++) {
      res.add(matcher.group(i));
    }

    return res;
  }

  // resolves . and .. elements in a path array with directory names there
  // must be no slashes, empty elements, or device names (c:\) in the array
  // (so also no leading and trailing slashes - it does not distinguish
  // relative and absolute paths)
  private array function normalizeArray(required array parts, boolean allowAboveRoot = false) {
    // if the path tries to go above the root, `up` ends up > 0
    var up = 0;
    for (var i = arrayLen(parts); i >= 1; i--) {
      var last = parts[i];
      if (last == '.') {
        arrayDeleteAt(parts, i);
      } else if (last == '..') {
        arrayDeleteAt(parts, i);
        up++;
      } else if (up) {
        arrayDeleteAt(parts, i);
        up--;
      }
    }

    // if the path is allowed to go above the root, restore leading ..s
    if (allowAboveRoot) {
      for (; up--; up) {
        parts.add(0, '..');
      }
    }

    return parts;
  }

  private array function trimArray(required array arr) {
    var start = 1;
    for (; start <= arrayLen(arr); start++) {
      if (arr[start] != '') break;
    }

    var end = arrayLen(arr);
    for (; end >= 1; end--) {
      if (arr[end] != '') break;
    }

    if (start > end) return [];
    return _arraySlice(arr, start, end - start + 1);
  }

  private array function _arraySlice(required array arr) {
      var start = 1;
      var end = arrayLen(arr);
      var slice = [];

      if (len(arguments[2])) start = arguments[2];
      if (len(arguments[3])) end = arguments[3];

      for (var i = start; i <= end; i++) {
          arrayAppend(slice, arr[i]);
      }
      
      return slice;
  }

}