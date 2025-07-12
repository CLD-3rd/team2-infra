$ServiceName = "savemypodo"
$dbPassword = $(aws ssm get-parameter --name "/$ServiceName/rds/admin_password" --with-decryption --query Parameter.Value --output text)

# MySQL init
mysql -h <RDS 엔드포인트> -P 3306 -u admin -p$dbPassword savemypodo < .\init.sql

# 이미지 업로드
$images = @(
    "lesmis.jpg",
    "wicked.jpg",
    "jekyll.webp",
    "hedwig.jpg",
    "lionking.webp",
    "phantom.jpg"
)

$bucketName = "$ServiceName-images"

foreach ($image in $images) {
    $localPath = ".\images\$image"
    $s3Path = "s3://$bucketName/musical_posters/$image"
    
    Write-Host "Uploading $localPath to $s3Path"
    aws s3 cp $localPath $s3Path
}
