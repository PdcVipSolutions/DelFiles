% Copyright (c) 2008-2015

implement main
    open core

domains
    task=
        file(string FileName);
        extList(string* ExtList).
clauses
    run() :-
        CommandLineDirty=mainExe::getCommandLine(),
        CommandLine=string::trim(CommandLineDirty),
        if not(CommandLine="") then
            Task=defineTask(CommandLine),
            if Task=file(FileName) then
                deleteFilesFromFile(FileName)
            elseif Task=extlist(ExtList) then
                FileList=getFileList(ExtList),
                deleteFileList(FileList),
                stdio::writef("Complete byExt %\n",ExtList)
            end if
        else
            stdio::writef("List of Extentions or filename must be")
        end if.

class predicates
    deleteFilesFromFile:(string FileName).
clauses
    deleteFilesFromFile(FileName):-
        if file::existExactFile(FileName) then
            FileListStr=file::readString(FileName),
            FileList=string::split_delimiter(FileListStr,"\n"),
            deleteFileList(FileList),
            stdio::writef("Complete %\n",FileName)
        else
            stdio::writef("File <%s> not exists!\n",FileName)
        end if.

class predicates
    deleteFileList:(string* FileList).
clauses
    deleteFileList(FileList):-
        _=[""||
            FileToDelete=list::getMember_nd(FileList),
            if
                file::existExactFile(FileToDelete)
            then
                try
                    file::delete(FileToDelete)
                catch _TraceID do
                    stdio::writef("Can not delete file %s\n",FileToDelete)
                end try
            else
                stdio::writef("File %s not found\n",FileToDelete)
            end if
        ].

class predicates
    getFileList:(string* ExtList)->string* FileList.
clauses
    getFileList(ExtList)=FileList:-
        FileList=[FileName||
            WildCard=list::getMember_nd(ExtList),
                FileName=directory::getFilesInDirectoryAndSub_nd(".\\",WildCard)
        ].
class predicates
    defineTask:(string CommandLine)->task Task.
clauses
    defineTask(CommandLine)=extList(ExtList):-
        '['=string::frontChar(CommandLine),
        ']'=string::lastChar(CommandLine),
        string::frontChar(CommandLine,_SB,Rest),
        string::lastChar(Rest,StrList,_LBx),
        ExtList=string::split_delimiter(StrList,","),
        !.
    defineTask(FileName)=file(FileName).

end implement main

goal
    console::runUtf8(main::run).