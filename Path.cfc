/**
 * @output false
 */
component {

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
    return arraySlice(arr, start, end - start + 1);
  }

  /**
   * Slices an array.
   * 
   * @param ary      The array to slice. (Required)
   * @param start      The index to start with. Defaults to 1. (Optional)
   * @param finish      The index to end with. Defaults to the end of the array. (Optional)
   * @return Returns an array. 
   * @author Darrell Maples (drmaples@gmail.com) 
   * @version 1, July 13, 2005 
   */
  private array function arraySlice(required array ary) {
      var start = 1;
      var finish = arrayLen(ary);
      var slice = arrayNew(1);
      var j = 1;

      if (len(arguments[2])) { start = arguments[2]; };
      if (len(arguments[3])) { finish = arguments[3]; };

      if (start <= 0) {
        return slice;
      }

      for (j=start; j LTE finish; j=j+1) {
          arrayAppend(slice, ary[j]);
      }
      
      return slice;
  }

}