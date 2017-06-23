<html>

% include('templates/head.tpl')

<body>
<div class="container">
    <div class="row">
        <div class="col-lg-12">

<h1>LAANO UPLOADER</h1>

<p>This <a href="https://laano.net" target="_blank">LaaNo</a> tool is used to upload Links and Notes to your Nextcloud storage.
Please check for the details: <a href="https://github.com/alexcustos/laano-tools" target="_blank">laano-tools</a>.</p>

%if errors:
    <ul class="text-danger">
        %for error in errors:
            <li>{{error}}</li>
        %end
    </ul>
%end

%if messages:
    <ul class="text-success">
        %for message in messages:
            <li>{{message}}</li>
        %end
    </ul>
%end

<h2>Directory</h2>
<p>{{directory}}</p>

<form action="/save" method="post" enctype="multipart/form-data" class="form-horizontal">
    <h2>Server</h2>
    <div class="form-group">
        <label class="col-sm-2 control-label">Hostname:</label>
        <div class="col-sm-10">
            <input name="hostname" class="form-control" type="text" size="50" value="{{data['hostname']}}">
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">Root:</label>
        <div class="col-sm-10">
            <input name="root" class="form-control" type="text" size="50" value="{{data['root']}}">
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">Login:</label>
        <div class="col-sm-10">
            <input name="login" class="form-control" type="text" size="20" value="{{data['login']}}">
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">Password:</label>
        <div class="col-sm-10">
            <input name="password" class="form-control" type="password" size="20" value="{{data['password']}}">
        </div>
    </div>

    <h2>Data</h2>
    <p>If URL and Note are specified both will be uploaded with the same tags, and Note will be bound to the Link.</p>
    <div class="form-group">
        <label class="col-sm-2 control-label">URL:</label>
        <div class="col-sm-10">
            <input name="url" class="form-control" type="text" size="50" value="{{data['url']}}" />
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">Title:</label>
        <div class="col-sm-10">
            <input name="title" class="form-control" type="text" size="50" value="{{data['title']}}" />
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">Note:</label>
        <div class="col-sm-10">
            <textarea name="note" class="form-control" rows="5" cols="50" />{{data['note']}}</textarea>
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">Tags:</label>
        <div class="col-sm-10">
            <input name="tags" class="form-control" type="text" size="50" value="{{data['tags']}}" />
        </div>
    </div>
    <div class="form-group">
        <div class="col-sm-offset-2 col-sm-10">
            <input class="btn btn-default" value="Upload Data" type="submit" />
        </div>
    </div>

    <h2>File</h2>
    <span class="help-block">
        <p class="bg-info info-padding">
            The file must be a text file (.txt) and must have the following format:<br />
            url:[url]<br />
            title:[title]<br />
            note:[note line 1]<br />
            ...<br />
            note:[note line N]<br />
            tags:[tags]<br />
            [new line]
        </p>
    </span>
    <div class="form-group">
        <label class="col-sm-2 control-label">Select a file:</label>
        <div class="col-sm-10">
            <input type="file" name="upload" />
        </div>
    </div>
    <div class="form-group">
        <div class="col-sm-offset-2 col-sm-10">
            <input class="btn btn-default" value="Upload File" type="submit" />
        </div>
    </div>
</form>

<p>&nbsp;</p>

        </div>
    </div>
</div>
</body>
</html>
