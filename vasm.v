import os
import flag
import lib.restr {String}

fn main() {
	mut fprs := flag.new_flag_parser(os.args)
	fprs.application('vasm')
	fprs.version('0.0.1')
	fprs.description('')
	fprs.skip_executable()

	path := fprs.string('file', `f`, '', 'File path')

	additional_args := fprs.finalize() or {
		eprintln(err)
		println(fprs.usage())
		return
	}

	if path != '' {
		mut txt := os.read_file(path)!
		for {
			start, end := String(txt).find(r'\{\{(.*)\}\}')
			if start == -1 {break}

			mut comp := txt[start+2 .. end-2]
			comp = os.read_file(comp)!
			txt = txt[..start] + comp + txt[end..]
		}
		
		println(txt)
		return
	}

	println(additional_args.join_lines())
	println(fprs.usage())
}