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

int size = 0;
struct stat mystat;
char filename[100];
int currentfd = -1;
int map_start;
char *addr;
char fieldBuffer[] = {0, 0, 0, 0};
char buf[9];
int debug = OFF;
Elf32_Ehdr* elfFile;

int main(int argc, char** argv){

	if(exemElfFile() == TRUE){

		printf("Entry point: 0x%x\n", elfFile->e_entry);
		printf("Num of sh: %d\n", elfFile->e_shnum);
	}

	printf("Exiting..\n");

	return 0;
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