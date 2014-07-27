{BufferedProcess} = require 'atom'
existsSync = require('fs').existsSync
writeFile = require('fs').writeFile

module.exports =
  configDefaults:
    go_executable_path: '/usr/local/bin/go'

  activate: ->
    atom.workspaceView.command "go-playground:execute", => @execute()

  execute: ->
    editor = atom.workspace.getActiveEditor()

    # unsaved file returns undefined
    current_file_path = editor.getPath()
    return unless current_file_path
    unless current_file_path.match(/\.go$/)
      return console.log('The file extention is not matched.')

    output_file_path = "#{atom.project.getPath()}/#{editor.getTitle()}.out"

    # evaluate go
    command = atom.config.get('go-playground.go_executable_path')

    if !existsSync(command)
        return alert('Please set the correct path to the go binary in the settings.', 'Go binary not found')

    args = ['run', current_file_path]
    stdout = (output) => @write_and_open_file(output_file_path, output)
    stderr = stdout
    process = new BufferedProcess({command, args, stdout, stderr})

  write_and_open_file: (path, output)->
    writeFile(path, output, (err)->
      if err
        console.error(err)

      else
        options = {
          split: 'right'

          # TODO not working??
          activatePane: false
        }

        activePane = atom.workspace.getActivePane()
        atom.workspace.open(path, options).done((newEditor)->
          # options.activatePane seems not to work, so reactivate prev pane.
          activePane.activate()
        )
    )
