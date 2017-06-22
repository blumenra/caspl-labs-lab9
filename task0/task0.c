#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <elf.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>


#define OFF 0
#define ON 1
#define TRUE 1
#define FALSE 0

void setFileName();
int exemElfFile();
void printPhdr(Elf32_Phdr* phdr);
void printPhdrTable();
void initilizeDebugger(int argc, char** argv);

int size = 0;
struct stat mystat;
char filename[100];
int currentfd = -1;
int map_start;
char *addr;
// char fieldBuffer[] = {0, 0, 0, 0};
// char buf[9];
int debug = OFF;
Elf32_Ehdr* elfFile;

int main(int argc, char** argv){

	initilizeDebugger(argc, argv);

	if(exemElfFile() == TRUE){

		printPhdrTable();
	}

	printf("Exiting..\n");

	return 0;
}

void printPhdrTable(){
	
	int phdrEntSize = elfFile->e_phentsize;
	int phdrCount = elfFile->e_phnum;

	if(debug){
		fprintf(stderr, "Debug: Phdr entry size: %d\n", phdrEntSize);
		fprintf(stderr, "Debug: number of entries: %d\n", phdrCount);
	}

	Elf32_Phdr* currPhdr;
	int i;
	printf("      Type Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Fig Align\n");
	for (i=0; i < phdrCount; i++){
		
		currPhdr = addr+elfFile->e_phoff+(i*phdrEntSize);
		printPhdr(currPhdr);
	}

}

void initilizeDebugger(int argc, char** argv){

	if(argc > 1){
		if(strcmp(argv[1], "-d") == 0){
			debug = ON;
		}
	}
}

void printPhdr(Elf32_Phdr* phdr){

	int  maxTypeWidth = 10;
	printf("%*x ", maxTypeWidth, phdr->p_type);
	printf("0x%06x ", phdr->p_offset);
	printf("0x%08x ", phdr->p_vaddr);
	printf("0x%08x ", phdr->p_paddr);
	printf("0x%05x ", phdr->p_filesz);
	printf("0x%05x ", phdr->p_memsz);
	printf("%3x ", phdr->p_flags);
	printf("0x%x", phdr->p_align);
	printf("\n");
}

void setFileName(){

	printf("Plaese enter a file name\n");
	fgets(filename, 100, stdin);

	//remove \n from filename
	int i=0;
	while(filename[i] != 0){
		if(filename[i] == '\n'){
			filename[i] = 0;
			break;
		}
		i++;
	}

	if(debug){
		printf("Debug: file name set to %s\n", filename);
	}
}

int exemElfFile(){

	setFileName();

	if(currentfd != -1){
		close(currentfd);
	}

	currentfd = open(filename, O_RDONLY);

	if(currentfd == -1){
		perror("open");
		return FALSE;
	}

	if(fstat(currentfd, &mystat) < 0){
		perror("fstat");
		currentfd = -1;
		close(currentfd);
		return FALSE;
	}

	addr = mmap(NULL, mystat.st_size, PROT_READ, MAP_PRIVATE, currentfd, 0);

	if(addr ==  MAP_FAILED){
		perror("mmap");
		currentfd = -1;
		close(currentfd);
		return FALSE;
	}

	if(strncmp(addr+1, "ELF", 3) != 0){
		fprintf(stderr, "This is not an ELF file!\n");
		currentfd = -1;
		close(currentfd);
		munmap(addr, mystat.st_size);
		return FALSE;
	}

	elfFile = (Elf32_Ehdr*) addr;

	return TRUE;
}