package bbs.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SampleController {
	
	@GetMapping("/business.do")
	public String business () throws Exception{
		return "business/main";
	}
	
	@GetMapping("/introduction.do")
	public String introduction () throws Exception{
		return "introduction/main";
	}
	
	@GetMapping("/technology.do")
	public String techonology () throws Exception{
		return "technology/main";
	}
	
	@GetMapping("/contest.do")
	public String contest () throws Exception{
		return "contest/main";
	}
	
}
