import os
import flag
import lib.restr {String}

fn main() {
	mut fprs := flag.new_flag_parser(os.args)
	fprs.application('vasm')
	fprs.version('0.0.1')
	fprs.description('')
	fprs.skip_executable()

	root := fprs.string('root', `d`, '', 'Root directory')

	additional_args := fprs.finalize() or {
		eprintln(err)
		println(fprs.usage())
		return
	}

	path := additional_args[0]

	if path != '' {
		mut txt := os.read_file(path)!
		for {
			start, end := String(txt).find(r'\[ins\]\((.*)\)')
			if start == -1 {break}

			mut comp := txt[start+6 .. end-1]
			comp = os.read_file(root + comp)!
			txt = txt[..start] + comp + txt[end..]
		}
		
		println(txt)
		return
	}

	println(additional_args.join_lines())
	println(fprs.usage())
}