var spawn = require('child_process').spawn,
    path = formatPath(process.argv[2]);

console.log('Docker directory: ' + path);

function formatPath(path) {
    path = path.replace(/\\/g, '/');
    path = path.replace(/:/, '');
    path = path.replace('d', '/vagrant');
    return path;
}

function sshIn() {
    spawn('C:\\Program Files (x86)\\PuTTY\\kitty.exe', ['-load', 'vagrant', '-cmd', 'cd ' + path], {
        detached: true,
        stdio: 'inherit'
    }).unref();
}

process.chdir('d:\\docker');

spawn('vagrant', ['status']).stdout.on('data', function(data) {
    var output = new Buffer(data).toString('utf8')

    if (output.indexOf('running') !== -1) {
        console.log('Vagrant is running');
        sshIn();
    } else {
        console.log('Vagrant need to be started');
        spawn('vagrant', ['up'], {
                stdio: ['ignore', 1, 2]
            })
            .on('exit', function() {
                sshIn();
            });
    }
});
