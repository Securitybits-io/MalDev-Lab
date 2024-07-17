PS C:\>Get-Partition -DiskNumber 3 -PartitionNumber 2
Disk Number: 3

PartitionNumber  DriveLetter Offset                                        Size Type
---------------  ----------- ------                                        ---- ----
2                D           135266304                                931.39 GB Basic

Resize the partition to 900GB.
PS C:\>Resize-Partition -DiskNumber 3 -PartitionNumber 2 -Size (900GB)


The partition is now 900GB.
PS C:\>Get-Partition -DiskNumber 3 -PartitionNumber 2
Disk Number: 3

PartitionNumber  DriveLetter Offset                                        Size Type
---------------  ----------- ------                                        ---- ----
2                D           135266304                                   900 GB Basic

Get the partition sizes.
PS C:\>$size = (Get-PartitionSupportedSize -DiskNumber 3 -PartitionNumber 2)


Resize to the maximum size.
PS C:\>Resize-Partition -DiskNumber 3 -PartitionNumber 2 -Size $size.SizeMax