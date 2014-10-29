<?
if ($_GET["package"]) {
	function zipFilesAndDownload($file_name,$archive_file_name) {
		$zip = new ZipArchive();
	
		//create the file and throw the error if unsuccessful
		if ($zip->open($archive_file_name, ZIPARCHIVE::CREATE )!==TRUE) {
			exit("cannot open <$archive_file_name>\n");
		}
	
		//add each files of package array to archive
		$zip->addFile("../".$file_name.".html",$file_name."/".$file_name.".html");
		$zip->addFile("../qml/".$file_name.".qml",$file_name."/"."qml/".$file_name.".qml");
		$zip->addFile("../css/styles.css",$file_name."/css/styles.css");
		$zip->addFile("README.txt",$file_name."/README.txt");
		
		foreach(glob('../images/*.*') as $filename) {
			$filename = str_replace("../images/","",$filename);
			$zip->addFile("images/".$filename,$file_name."/images/".$filename);
		}
		
		$zip->close();

		//then send the headers to foce download the zip file
		header("Content-type: application/zip"); 
		header("Content-Disposition: attachment; filename=$archive_file_name");
		header("Content-length: " . filesize($archive_file_name));
		header("Pragma: no-cache"); 
		header("Expires: 0"); 
		readfile("$archive_file_name");
		exit;
	}
	
	
	//Archive name
	$archive_file_name=$_GET["package"].'.zip';
	
	zipFilesAndDownload($_GET["package"],$archive_file_name);
} else {
	echo "Error: No package was selected.";
}
?>