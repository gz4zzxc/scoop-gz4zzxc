#!/usr/bin/env python3
"""
Simple script to validate Scoop manifest JSON files
"""

import json
import os
import sys
from pathlib import Path

def validate_manifest(manifest_path):
    """Validate a single manifest file"""
    try:
        with open(manifest_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Check required fields
        required_fields = ['version', 'description', 'homepage', 'license']
        missing_fields = [field for field in required_fields if field not in data]
        
        if missing_fields:
            print(f"❌ {manifest_path}: Missing required fields: {missing_fields}")
            return False
        
        # Check if URL is present (either direct or in architecture)
        has_url = 'url' in data or ('architecture' in data and 
                                   any('url' in arch for arch in data['architecture'].values()))
        
        if not has_url:
            print(f"❌ {manifest_path}: No download URL found")
            return False
        
        print(f"✅ {manifest_path}: Valid manifest")
        print(f"   Version: {data['version']}")
        print(f"   Description: {data['description'][:60]}...")
        return True
        
    except json.JSONDecodeError as e:
        print(f"❌ {manifest_path}: Invalid JSON - {e}")
        return False
    except Exception as e:
        print(f"❌ {manifest_path}: Error - {e}")
        return False

def main():
    """Main function to validate all manifests in bucket directory"""
    bucket_dir = Path(__file__).parent.parent / 'bucket'
    
    if not bucket_dir.exists():
        print("❌ Bucket directory not found")
        sys.exit(1)
    
    manifest_files = list(bucket_dir.glob('*.json'))
    
    if not manifest_files:
        print("❌ No manifest files found in bucket directory")
        sys.exit(1)
    
    print(f"Validating {len(manifest_files)} manifest files...\n")
    
    valid_count = 0
    for manifest_file in manifest_files:
        if validate_manifest(manifest_file):
            valid_count += 1
        print()
    
    print(f"Results: {valid_count}/{len(manifest_files)} manifests are valid")
    
    if valid_count == len(manifest_files):
        print("🎉 All manifests are valid!")
        sys.exit(0)
    else:
        print("❌ Some manifests have issues")
        sys.exit(1)

if __name__ == '__main__':
    main()
