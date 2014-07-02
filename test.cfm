<cffunction name="printResults">
  <cfoutput>
  <table>
    <cfloop array="#results#" index="result">
      <tr>
        <td style="<cfif not result.success> background: red;</cfif>">"#result.data.a#" is<cfif not result.success> not</cfif> equal to "#result.data.b#"</td>
      </tr>
    </cfloop>
  </table>
  </cfoutput>
</cffunction>
<cfscript>

  results = [];

  function isEqual(required string a, required string b) {
    var res = {
      data = arguments,
      success = compare(a, b) == 0
    };
    arrayAppend(results, res);
  }

  function isBooleanEqual(required boolean a, required boolean b) {
    var res = {
      data = arguments,
      success = a == b
    };
    arrayAppend(results, res);
  }

  path = new Path();

  f = getCurrentTemplatePath();

  isEqual(path.basename(f), 'test.cfm');
  isEqual(path.basename(f, '.cfm'), 'test');
  isEqual(path.basename(''), '');
  isEqual(path.basename('/dir/basename.ext'), 'basename.ext');
  isEqual(path.basename('/basename.ext'), 'basename.ext');
  isEqual(path.basename('basename.ext'), 'basename.ext');
  isEqual(path.basename('basename.ext/'), 'basename.ext');
  isEqual(path.basename('basename.ext//'), 'basename.ext');

  // On unix a backslash is just treated as any other character.
  isEqual(path.basename('\\dir\\basename.ext'), '\\dir\\basename.ext');
  isEqual(path.basename('\\basename.ext'), '\\basename.ext');
  isEqual(path.basename('basename.ext'), 'basename.ext');
  isEqual(path.basename('basename.ext\\'), 'basename.ext\\');
  isEqual(path.basename('basename.ext\\\\'), 'basename.ext\\\\');

  isEqual(path.extname(f), '.cfm');

  isEqual(path.dirname('/a/b/'), '/a');
  isEqual(path.dirname('/a/b'), '/a');
  isEqual(path.dirname('/a'), '/');
  isEqual(path.dirname(''), '.');
  isEqual(path.dirname('/'), '/');
  isEqual(path.dirname('////'), '/');

  isEqual(path.extname(''), '');
  isEqual(path.extname('/path/to/file'), '');
  isEqual(path.extname('/path/to/file.ext'), '.ext');
  isEqual(path.extname('/path.to/file.ext'), '.ext');
  isEqual(path.extname('/path.to/file'), '');
  isEqual(path.extname('/path.to/.file'), '');
  isEqual(path.extname('/path.to/.file.ext'), '.ext');
  isEqual(path.extname('/path/to/f.ext'), '.ext');
  isEqual(path.extname('/path/to/..ext'), '.ext');
  isEqual(path.extname('file'), '');
  isEqual(path.extname('file.ext'), '.ext');
  isEqual(path.extname('.file'), '');
  isEqual(path.extname('.file.ext'), '.ext');
  isEqual(path.extname('/file'), '');
  isEqual(path.extname('/file.ext'), '.ext');
  isEqual(path.extname('/.file'), '');
  isEqual(path.extname('/.file.ext'), '.ext');
  isEqual(path.extname('.path/file.ext'), '.ext');
  isEqual(path.extname('file.ext.ext'), '.ext');
  isEqual(path.extname('file.'), '.');
  isEqual(path.extname('.'), '');
  isEqual(path.extname('./'), '');
  isEqual(path.extname('.file.ext'), '.ext');
  isEqual(path.extname('.file'), '');
  isEqual(path.extname('.file.'), '.');
  isEqual(path.extname('.file..'), '.');
  isEqual(path.extname('..'), '');
  isEqual(path.extname('../'), '');
  isEqual(path.extname('..file.ext'), '.ext');
  isEqual(path.extname('..file'), '.file');
  isEqual(path.extname('..file.'), '.');
  isEqual(path.extname('..file..'), '.');
  isEqual(path.extname('...'), '.');
  isEqual(path.extname('...ext'), '.ext');
  isEqual(path.extname('....'), '.');
  isEqual(path.extname('file.ext/'), '.ext');
  isEqual(path.extname('file.ext//'), '.ext');
  isEqual(path.extname('file/'), '');
  isEqual(path.extname('file//'), '');
  isEqual(path.extname('file./'), '.');
  isEqual(path.extname('file.//'), '.');

  // On unix, backspace is a valid name component like any other character.
  isEqual(path.extname('.\\'), '');
  isEqual(path.extname('..\\'), '.\\');
  isEqual(path.extname('file.ext\\'), '.ext\\');
  isEqual(path.extname('file.ext\\\\'), '.ext\\\\');
  isEqual(path.extname('file\\'), '');
  isEqual(path.extname('file\\\\'), '');
  isEqual(path.extname('file.\\'), '.\\');
  isEqual(path.extname('file.\\\\'), '.\\\\');



  // path.join tests
  public any function argumentArray(required array orderedArguments) {
    var argumentCollection = createObject('java', 'java.util.TreeMap').init();

    for( var i = 1; i <= arrayLen(orderedArguments); i++ ) {
      argumentCollection.put(
        javaCast('string', i),
        orderedArguments[i]
      );
    }

    return argumentCollection;
  }

  failures = [];
  joinTests =
      // arguments                     result
      [[['.', 'x/b', '..', '/b/c.js'], 'x/b/c.js'],
       [['/.', 'x/b', '..', '/b/c.js'], '/x/b/c.js'],
       [['/foo', '../../../bar'], '/bar'],
       [['foo', '../../../bar'], '../../bar'],
       [['foo/', '../../../bar'], '../../bar'],
       [['foo/x', '../../../bar'], '../bar'],
       [['foo/x', './bar'], 'foo/x/bar'],
       [['foo/x/', './bar'], 'foo/x/bar'],
       [['foo/x/', '.', 'bar'], 'foo/x/bar'],
       [['./'], './'],
       [['.', './'], './'],
       [['.', '.', '.'], '.'],
       [['.', './', '.'], '.'],
       [['.', '/./', '.'], '.'],
       [['.', '/////./', '.'], '.'],
       [['.'], '.'],
       [['', '.'], '.'],
       [['', 'foo'], 'foo'],
       [['foo', '/bar'], 'foo/bar'],
       [['', '/foo'], '/foo'],
       [['', '', '/foo'], '/foo'],
       [['', '', 'foo'], 'foo'],
       [['foo', ''], 'foo'],
       [['foo/', ''], 'foo/'],
       [['foo', '', '/bar'], 'foo/bar'],
       [['./', '..', '/foo'], '../foo'],
       [['./', '..', '..', '/foo'], '../../foo'],
       [['.', '..', '..', '/foo'], '../../foo'],
       [['', '..', '..', '/foo'], '../../foo'],
       [['/'], '/'],
       [['/', '.'], '/'],
       [['/', '..'], '/'],
       [['/', '..', '..'], '/'],
       [[''], '.'],
       [['', ''], '.'],
       [[' /foo'], ' /foo'],
       [[' ', 'foo'], ' /foo'],
       [[' ', '.'], ' '],
       [[' ', '/'], ' /'],
       [[' ', ''], ' '],
       [['/', 'foo'], '/foo'],
       [['/', '/foo'], '/foo'],
       [['/', '//foo'], '/foo'],
       [['/', '', '/foo'], '/foo'],
       [['', '/', 'foo'], '/foo'],
       [['', '/', '/foo'], '/foo']
      ];

  for (i = 1; i <= arrayLen(joinTests); i++) {
    test = joinTests[i];
    isEqual(path.join(argumentCollection = argumentArray(test[1])), test[2]);
  }



  // path normalize tests
  isEqual(path.normalize('./fixtures///b/../b/c.js'),
               'fixtures/b/c.js');
  isEqual(path.normalize('/foo/../../../bar'), '/bar');
  isEqual(path.normalize('a//b//../b'), 'a/b');
  isEqual(path.normalize('a//b//./c'), 'a/b/c');
  isEqual(path.normalize('a//b//.'), 'a/b');





  // path.resolve tests
  resolveTests =
      // arguments                                    result
      [[['/var/lib', '../', 'file/'], '/var/file'],
       [['/var/lib', '/../', 'file/'], '/file'],
       //[['a/b/c/', '../../..'], process.cwd()],
       //[['.'], process.cwd()],
       [['/some/dir', '.', '/absolute/'], '/absolute']];

  for (i = 1; i <= arrayLen(resolveTests); i++) {
    test = resolveTests[i];
    isEqual(path.resolve(argumentCollection = argumentArray(test[1])), test[2]);
  }




  // path.isAbsolute tests
  isBooleanEqual(path.isAbsolute('/home/foo'), true);
  isBooleanEqual(path.isAbsolute('/home/foo/..'), true);
  isBooleanEqual(path.isAbsolute('bar/'), false);
  isBooleanEqual(path.isAbsolute('./baz'), false);








  printResults();

  writeDump(path); abort;

</cfscript>