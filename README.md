# FILESCAN: File System Forensics and AI Interpreter 

## Team Members
- Caitlyn Cashion
- Zainab Onibudo

## Project Idea 
Collect file system data by scanning a specific directory, and extract attributes such as file size, file permissions, file name, modifications, etc. With the knowledge of these attributes, a timeline will be created in order to see file acitvity in chronological order. Along with this extraction, we will also expand into file carving. 

This will be executed by creating a bash script that accepts the directory as its input, files in that directory will be scanned, metadata file will be extracted and then the timeline will be created based off the data being formatted. This timeline will then be outputted as a text file. 

AI Use: AI will read through the file system data that was scanned, and output results in laymans terms. This will be used by using an API key.

## Project Overview
FileScan is a bash and Python toolkit for digital forensics designed to analyze suspicious directories on a Linux system. The tool is able to automate the process of combing through file attributes. It is executed by: 
- Scanning a target directory and extracting metadata for every file
- Builiding an activity timeline in chronological order. It is ordered by modification time
- Carving deleted or hidden file fragments from a raw image via Foremost
- Interpreting the results through the Claude API. It will output a a summary in plain English, making it easier to understand

## Features 
- Metadata Extraction: File name, size, permissions, owner, MD5 hash, and MIME type
- Access, Modify, and Change timestamps: Full atime, mtime, and ctime per file
- Chronological Timeline: All files will be sorted oldest to newest, based on the date and time it was modified
- File Carving: Recovers deleted file fragments
- AI Summary: Claude API reads the scan data and will output a summary in a friendly-view report
- Organization: Every time a scan is executed, it will be saved to a timestamp folder. The script also ensures no past run will be overwritten

## How to use FileScan
- Make sure you are on a Linux system (Preferbly Kali Linux)
### Tools Required


