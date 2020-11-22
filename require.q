/ Greatly stripped down buabook require framework, no initialisation is coded https://github.com/BuaBook/kdb-common/blob/master/src/require.q

.require.fileSuffixes:(".q";".k";".*.q";".*.k";".q_";".*.q_");

/ Root folder to search for libraries
.require.location.root:`;

/ Regexs to filter discovered files
.require.location.ignore:("*.git";"*target");

/ Complete list of discovered files from the libs directory
.require.location.discovered:enlist`;

.require.init:{[root]
    $[null root;
        .require.location.root:.require.i.getCwd[];
        .require.location.root:root
    ];
    
    / If file tree has already been specified, don't overwrite
    if[.require.location.discovered~enlist`;
        .require.rescanRoot[];
    ];

 };

.require.i.getCwd:{
    os:first string .z.o;
    if["w"~os;
        :hsym first `$trim system "echo %cd%";
    ];
    if[os in "lms";
        :hsym first `$trim system "pwd";
    ];
    '"OsNotSupportedForCwdException (",string[.z.o],")";
 };

.require.i.load:{[lib]

    libFiles:.require.i.findFiles[lib;.require.location.discovered];
    {
        loadRes:@[system;"l ",x;{ (`LOAD_FAILURE;x) }];
    } each 1_/:string libFiles;
    
 };

.require.rescanRoot:{
    .require.location.discovered:.require.i.tree .require.location.root;
 };

.require.lib:{[lib]
    .require.i.load@\:lib;
 };

.require.i.findFiles:{[lib;files]
    filesNoPath:last each ` vs/:files;
    :files where any filesNoPath like/: string[lib],/:.require.fileSuffixes;
 };

.require.i.tree:{[root]
    rc:` sv/:root,/:key root;
    rc:rc where not any rc like\:/:.require.location.ignore;

    folders:.require.i.isFolder each rc;

    :raze (rc where not folders),.z.s each rc where folders;
 };

.require.i.isFolder:{[folder]
    :(not ()~fc) & not folder~fc:key folder;
 };


.require.init[];