$ServiceName = "savemypodo"
$dbPassword = $(aws ssm get-parameter --name "/$ServiceName/rds/admin_password" --with-decryption --query Parameter.Value --output text)

# MySQL init
cmd /c "mysql --default-character-set=utf8mb4 -h savemypodo-mysql.c3qme6c6e7fj.ap-northeast-2.rds.amazonaws.com -P 3306 -u admin -p$($dbPassword) savemypodo < init.sql"

# 이미지 업로드
$images = @(
    "lesmis.jpeg",
    "wicked.jpeg",
    "jekyll.webp",
    "hedwig.jpeg",
    "lionking.webp",
    "phantom.jpeg"
)

$bucketName = "$ServiceName-images"

foreach ($image in $images) {
    $localPath = ".\images\$image"
    $s3Path = "s3://$bucketName/musical_posters/$image"
    
    Write-Host "Uploading $localPath to $s3Path"
    aws s3 cp $localPath $s3Path
}
